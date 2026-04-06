#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from build_grocery_list import normalize_name, normalize_unit, parse_quantity
from numbers_sync import dump_tables, timestamp_now, write_pricing_payload
from workbook_schema import DEFAULT_WORKBOOK_PATH


RETAILER_SCRIPT = SCRIPT_DIR / "retailer_scrape.mjs"
PACKAGE_UNITS = ("fl oz", "oz", "lb", "gal", "ct", "ea", "pkg", "bag", "bunch", "slice", "clove")


def preferences_map(profile_rows: list[dict[str, object]]) -> dict[str, str]:
    return {
        str(row.get("key", "")): str(row.get("value", ""))
        for row in profile_rows
        if str(row.get("key", "")).strip()
    }


def parse_package_size(size_text: str) -> tuple[float | None, str]:
    normalized = size_text.strip().lower()
    for unit in PACKAGE_UNITS:
        match = None
        if unit == "fl oz":
            match = normalize_match(normalized, r"(\d+(?:\.\d+)?)\s*(fl oz)")
        else:
            match = normalize_match(normalized, rf"(\d+(?:\.\d+)?)\s*({unit})")
        if match:
            quantity = parse_quantity(match.group(1))
            return quantity, normalize_unit(match.group(2))
    return None, ""


def normalize_match(text: str, pattern: str):
    import re

    return re.search(pattern, text, re.IGNORECASE)


def candidate_score(query: str, candidate: dict[str, object], requested_unit: str) -> float:
    query_tokens = set(normalize_name(query).split())
    title_tokens = set(normalize_name(str(candidate.get("title", ""))).split())
    if not query_tokens or not title_tokens:
        return 0.0

    overlap = len(query_tokens & title_tokens) / len(query_tokens)
    score = overlap

    size_text = normalize_name(str(candidate.get("size", "")))
    normalized_unit = normalize_unit(requested_unit)
    if normalized_unit and normalized_unit in size_text:
        score += 0.1

    mismatch_terms = {"chicken", "beef", "pork", "salmon", "shrimp", "tofu", "milk", "bread", "egg"}
    query_specific = query_tokens & mismatch_terms
    title_specific = title_tokens & mismatch_terms
    if query_specific and title_specific and query_specific != title_specific:
        score -= 0.2

    return round(score, 4)


def estimate_line_price(row: dict[str, object], candidate: dict[str, object]) -> float | None:
    price = candidate.get("price")
    if not isinstance(price, (int, float)):
        return None

    requested_quantity = parse_quantity(row.get("total_quantity"))
    requested_unit = normalize_unit(row.get("unit", ""))
    package_quantity, package_unit = parse_package_size(str(candidate.get("size", "")))
    if (
        requested_quantity is not None
        and package_quantity
        and requested_unit
        and requested_unit == package_unit
        and package_quantity > 0
    ):
        package_count = max(1, math.ceil(requested_quantity / package_quantity))
        return round(float(price) * package_count, 2)
    return round(float(price), 2)


def choose_candidate(
    retailer: str,
    row: dict[str, object],
    retailer_result: dict[str, object],
    expected_store: str,
    expected_zip: str,
) -> dict[str, object]:
    actual_store = str(retailer_result.get("actual_store", "")).strip()
    candidates = list(retailer_result.get("candidates", []))
    review_notes: list[str] = []

    if not candidates:
        return {
            f"{retailer}_status": "unavailable",
            f"{retailer}_store": actual_store,
            f"{retailer}_product": "",
            f"{retailer}_size": "",
            f"{retailer}_unit_price": "",
            f"{retailer}_line_price": "",
            f"{retailer}_url": "",
            f"{retailer}_scraped_at": timestamp_now(),
            "review_flag": f"{retailer} unavailable",
        }

    requested_unit = str(row.get("unit", ""))
    scored = sorted(
        (
            (
                candidate_score(str(row.get("ingredient_name") or row.get("normalized_name") or ""), candidate, requested_unit),
                candidate,
            )
            for candidate in candidates
        ),
        key=lambda item: item[0],
        reverse=True,
    )
    best_score, best_candidate = scored[0]
    runner_up_score = scored[1][0] if len(scored) > 1 else 0.0
    status = "matched"

    if best_score < 0.55:
        status = "review"
        review_notes.append(f"{retailer} weak match")
    if len(scored) > 1 and (best_score - runner_up_score) < 0.08:
        status = "review"
        review_notes.append(f"{retailer} ambiguous")
    if expected_store and actual_store and expected_store.lower() not in actual_store.lower():
        if expected_zip and expected_zip in actual_store:
            pass
        else:
            status = "review"
            review_notes.append(f"{retailer} store mismatch")

    line_price = estimate_line_price(row, best_candidate)
    product_url = str(best_candidate.get("url", ""))
    output = {
        f"{retailer}_status": status,
        f"{retailer}_store": actual_store,
        f"{retailer}_product": str(best_candidate.get("title", "")),
        f"{retailer}_size": str(best_candidate.get("size", "")),
        f"{retailer}_unit_price": best_candidate.get("price", ""),
        f"{retailer}_line_price": line_price if line_price is not None else "",
        f"{retailer}_url": product_url,
        f"{retailer}_scraped_at": timestamp_now(),
    }
    if review_notes:
        output["review_flag"] = "; ".join(review_notes)
    return output


def run_playwright_worker(request_path: Path, output_path: Path) -> None:
    cmd = [
        "npx",
        "--yes",
        "--package",
        "playwright",
        "node",
        str(RETAILER_SCRIPT),
        "--input",
        str(request_path),
        "--output",
        str(output_path),
    ]
    completed = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if completed.returncode == 0:
        return

    install_cmd = [
        "npx",
        "--yes",
        "--package",
        "playwright",
        "playwright",
        "install",
        "chromium",
    ]
    install = subprocess.run(install_cmd, capture_output=True, text=True, check=False)
    if install.returncode != 0:
        raise RuntimeError(completed.stderr.strip() or install.stderr.strip() or "Unable to install Playwright Chromium")

    retry = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if retry.returncode != 0:
        raise RuntimeError(retry.stderr.strip() or "Retailer scrape failed")


def fetch_store_prices(
    workbook_path: Path = DEFAULT_WORKBOOK_PATH,
    limit: int = 5,
) -> dict[str, object]:
    state = dump_tables(workbook_path, "all")
    tables = state["tables"]
    preferences = preferences_map(tables["Profile.Preferences"])
    grocery_rows = list(tables["Current Week.GroceryList"])
    week_meta = list(tables["Current Week.WeekMeta"])
    week_start = str(week_meta[0].get("week_start", "")) if week_meta else ""

    request_rows = [
        {
            "grocery_item_id": row.get("grocery_item_id", ""),
            "query": str(row.get("ingredient_name") or row.get("normalized_name") or ""),
            "unit": str(row.get("unit", "")),
            "limit": limit,
        }
        for row in grocery_rows
        if str(row.get("ingredient_name") or row.get("normalized_name") or "").strip()
    ]

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_root = Path(temp_dir)
        request_path = temp_root / "pricing-request.json"
        response_path = temp_root / "pricing-response.json"
        request_payload = {
            "stores": {
                "aldi": {
                    "name": preferences.get("aldi_store_name", ""),
                    "zip": preferences.get("aldi_store_zip", ""),
                    "store_id": preferences.get("aldi_store_id", ""),
                },
                "walmart": {
                    "name": preferences.get("walmart_store_name", ""),
                    "zip": preferences.get("walmart_store_zip", ""),
                    "store_id": preferences.get("walmart_store_id", ""),
                },
            },
            "queries": request_rows,
        }
        request_path.write_text(json.dumps(request_payload))
        run_playwright_worker(request_path, response_path)
        response_payload = json.loads(response_path.read_text())

    by_retailer: dict[str, dict[str, dict[str, object]]] = {"aldi": {}, "walmart": {}}
    actual_stores = {
        "aldi": str(response_payload.get("aldi", {}).get("actual_store", "")),
        "walmart": str(response_payload.get("walmart", {}).get("actual_store", "")),
    }
    for retailer in ("aldi", "walmart"):
        for result in response_payload.get(retailer, {}).get("results", []):
            by_retailer[retailer][str(result.get("grocery_item_id", ""))] = dict(result)

    pricing_rows: list[dict[str, object]] = []
    totals = {"aldi": 0.0, "walmart": 0.0}
    statuses = {"matched": 0, "review": 0, "unavailable": 0, "error": 0}

    for row in grocery_rows:
        grocery_item_id = str(row.get("grocery_item_id", ""))
        merged = {"grocery_item_id": grocery_item_id}
        review_flags = [str(row.get("review_flag", "")).strip()] if str(row.get("review_flag", "")).strip() else []

        for retailer in ("aldi", "walmart"):
            result = by_retailer[retailer].get(grocery_item_id, {"actual_store": actual_stores.get(retailer, ""), "candidates": []})
            chosen = choose_candidate(
                retailer,
                row,
                result,
                preferences.get(f"{retailer}_store_name", ""),
                preferences.get(f"{retailer}_store_zip", ""),
            )
            merged.update(chosen)
            status = str(chosen.get(f"{retailer}_status", ""))
            if status in statuses:
                statuses[status] += 1
            line_price = chosen.get(f"{retailer}_line_price")
            if isinstance(line_price, (int, float)):
                totals[retailer] += float(line_price)
            note = str(chosen.get("review_flag", "")).strip()
            if note:
                review_flags.append(note)

        merged["review_flag"] = "; ".join(flag for flag in review_flags if flag)
        pricing_rows.append(merged)

    write_result = write_pricing_payload({"week_start": week_start, "pricing_rows": pricing_rows}, workbook_path)
    return {
        "status": "ok",
        "workbook_path": str(workbook_path),
        "week_start": week_start,
        "rows_priced": len(pricing_rows),
        "totals": {key: round(value, 2) for key, value in totals.items()},
        "statuses": statuses,
        "stores": actual_stores,
        "write_result": write_result,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch Aldi and Walmart pricing for the active grocery list.")
    parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK_PATH)
    parser.add_argument("--limit", type=int, default=5, help="Candidate count per retailer query.")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    result = fetch_store_prices(args.workbook, args.limit)
    print(json.dumps(result, indent=2 if args.pretty else None))


if __name__ == "__main__":
    main()
