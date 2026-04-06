#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import os
import subprocess
import sys
from datetime import datetime
from io import StringIO
from pathlib import Path
from zoneinfo import ZoneInfo

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from bootstrap_workbook import bootstrap_workbook
from build_grocery_list import split_recipe_rows
from workbook_schema import (
    DEFAULT_WORKBOOK_PATH,
    HISTORY_MIRRORS,
    PROFILE_DEFAULTS,
    TABLE_SPECS,
    column_format,
    coerce_cell_value,
    empty_row,
    table_keys_for_section,
)


TIMEZONE = ZoneInfo("America/Chicago")


def timestamp_now() -> str:
    return datetime.now(TIMEZONE).isoformat(timespec="seconds")


def applescript_literal(value: object) -> str:
    if value is None:
        return '""'
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return str(value)
    text = str(value).replace("\\", "\\\\").replace('"', '\\"')
    return f'"{text}"'


def cell_literal(table_name: str, column_name: str, value: object) -> str:
    if column_format(table_name, column_name) == "number" and isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, bool):
        return applescript_literal(str(value).lower())
    return applescript_literal(value)


def run_osascript(script: str, workbook_path: Path | None = None) -> str:
    env = dict(os.environ)
    if workbook_path is not None:
        env["WORKBOOK_PATH"] = str(workbook_path)
    completed = subprocess.run(
        ["osascript"],
        input=script,
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(completed.stderr.strip() or "AppleScript execution failed")
    return completed.stdout


def build_read_script(table_name: str) -> str:
    spec = TABLE_SPECS[table_name]
    return "\n".join(
        [
            "on joinList(itemList, delimiter)",
            "set oldDelimiters to AppleScript's text item delimiters",
            "set AppleScript's text item delimiters to delimiter",
            "set joinedText to itemList as text",
            "set AppleScript's text item delimiters to oldDelimiters",
            "return joinedText",
            "end joinList",
            'set workbookPath to system attribute "WORKBOOK_PATH"',
            'tell application "Numbers"',
            "activate",
            "open POSIX file workbookPath",
            "delay 0.2",
            "set docRef to front document",
            f"tell sheet {applescript_literal(spec.sheet)} of docRef",
            f"tell table {applescript_literal(spec.table)}",
            "set outputLines to {}",
            "repeat with rowIndex from 1 to row count",
            "set rowValues to {}",
            "repeat with columnIndex from 1 to column count",
            "tell cell columnIndex of row rowIndex",
            "if value is missing value then",
            'set end of rowValues to ""',
            "else",
            "try",
            "set end of rowValues to value as text",
            "on error",
            "set end of rowValues to formatted value as text",
            "end try",
            "end if",
            "end tell",
            "end repeat",
            'set end of outputLines to my joinList(rowValues, character id 9)',
            "end repeat",
            "end tell",
            "end tell",
            "save docRef",
            "end tell",
            "return my joinList(outputLines, linefeed)",
        ]
    )


def parse_table_output(table_name: str, raw_output: str) -> list[dict[str, object]]:
    if not raw_output.strip():
        return []

    reader = csv.reader(StringIO(raw_output), delimiter="\t")
    rows = list(reader)
    if not rows:
        return []

    header = rows[0]
    data_rows: list[dict[str, object]] = []
    for values in rows[1:]:
        padded = values + [""] * (len(header) - len(values))
        if not any(cell.strip() for cell in padded):
            continue
        row = {
            header[index]: coerce_cell_value(table_name, header[index], padded[index])
            for index in range(len(header))
        }
        data_rows.append(row)
    return data_rows


def read_table(workbook_path: Path, table_name: str) -> list[dict[str, object]]:
    raw_output = run_osascript(build_read_script(table_name), workbook_path=workbook_path)
    return parse_table_output(table_name, raw_output)


def build_write_script(table_name: str, rows: list[dict[str, object]]) -> str:
    spec = TABLE_SPECS[table_name]
    normalized_rows: list[dict[str, object]] = []
    for row in rows:
        normalized = empty_row(table_name)
        for column in spec.columns:
            if column in row:
                normalized[column] = row[column]
        normalized_rows.append(normalized)

    row_count = max(2, len(normalized_rows) + 1)
    lines = [
        'set workbookPath to system attribute "WORKBOOK_PATH"',
        'tell application "Numbers"',
        "activate",
        "open POSIX file workbookPath",
        "delay 0.2",
        "set docRef to front document",
        f"tell sheet {applescript_literal(spec.sheet)} of docRef",
        f"tell table {applescript_literal(spec.table)}",
        f"set row count to {row_count}",
        f"set column count to {len(spec.columns)}",
        f"set header row count to {spec.header_rows}",
        "end tell",
    ]

    for column_index, column_name in enumerate(spec.columns, start=1):
        lines.append(
            f"tell table {applescript_literal(spec.table)} to tell column {column_index} to set format to {column_format(table_name, column_name)}"
        )
        lines.append(
            f"tell table {applescript_literal(spec.table)} to tell cell {column_index} of row 1 to set value to {applescript_literal(column_name)}"
        )

    if normalized_rows:
        for row_index, row in enumerate(normalized_rows, start=2):
            for column_index, column_name in enumerate(spec.columns, start=1):
                lines.append(
                    f"tell table {applescript_literal(spec.table)} to tell cell {column_index} of row {row_index} to set value to {cell_literal(table_name, column_name, row.get(column_name, ''))}"
                )
    else:
        for column_index in range(1, len(spec.columns) + 1):
            lines.append(
                f'tell table {applescript_literal(spec.table)} to tell cell {column_index} of row 2 to set value to ""'
            )

    lines.extend(
        [
            "end tell",
            "save docRef",
            "end tell",
        ]
    )
    return "\n".join(lines)


def write_table(workbook_path: Path, table_name: str, rows: list[dict[str, object]]) -> None:
    run_osascript(build_write_script(table_name, rows), workbook_path=workbook_path)


def dump_tables(workbook_path: Path = DEFAULT_WORKBOOK_PATH, section: str = "all") -> dict[str, object]:
    bootstrap_workbook(workbook_path=workbook_path)
    tables = {
        table_name: read_table(workbook_path, table_name)
        for table_name in table_keys_for_section(section)
    }
    return {"workbook_path": str(workbook_path), "section": section, "tables": tables}


def profile_rows_to_map(rows: list[dict[str, object]]) -> dict[str, dict[str, object]]:
    return {str(row.get("key", "")): dict(row) for row in rows if str(row.get("key", "")).strip()}


def merge_profile_updates(
    existing_rows: list[dict[str, object]],
    updates: dict[str, object] | list[dict[str, object]],
) -> list[dict[str, object]]:
    merged = profile_rows_to_map(existing_rows)
    if isinstance(updates, dict):
        update_rows = [{"key": key, "value": value, "updated_at": timestamp_now()} for key, value in updates.items()]
    else:
        update_rows = []
        for row in updates:
            key = str(row.get("key", "")).strip()
            if not key:
                continue
            update_rows.append(
                {
                    "key": key,
                    "value": row.get("value", ""),
                    "updated_at": row.get("updated_at", timestamp_now()),
                }
            )

    for row in update_rows:
        merged[row["key"]] = row

    ordered_keys = list(PROFILE_DEFAULTS.keys())
    tail_keys = sorted(key for key in merged if key not in ordered_keys)
    result = []
    for key in ordered_keys + tail_keys:
        if key in merged:
            result.append(merged[key])
    return result


def merge_recipe_tables(
    existing_recipes: list[dict[str, object]],
    existing_ingredients: list[dict[str, object]],
    new_recipes: list[dict[str, object]],
    new_ingredients: list[dict[str, object]],
) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    recipe_index = {str(row.get("recipe_id", "")): dict(row) for row in existing_recipes if str(row.get("recipe_id", "")).strip()}
    for row in new_recipes:
        recipe_id = str(row.get("recipe_id", "")).strip()
        if not recipe_id:
            continue
        combined = dict(recipe_index.get(recipe_id, empty_row("Recipes.Recipes")))
        combined.update({column: row.get(column, combined.get(column, "")) for column in TABLE_SPECS["Recipes.Recipes"].columns})
        recipe_index[recipe_id] = combined

    replace_recipe_ids = {str(row.get("recipe_id", "")).strip() for row in new_ingredients if str(row.get("recipe_id", "")).strip()}
    merged_ingredients = [
        dict(row)
        for row in existing_ingredients
        if str(row.get("recipe_id", "")).strip() not in replace_recipe_ids
    ]
    for row in new_ingredients:
        normalized = empty_row("Recipes.RecipeIngredients")
        normalized.update({column: row.get(column, "") for column in TABLE_SPECS["Recipes.RecipeIngredients"].columns})
        merged_ingredients.append(normalized)

    recipe_rows = sorted(recipe_index.values(), key=lambda row: str(row.get("name", "")).lower())
    ingredient_rows = sorted(
        merged_ingredients,
        key=lambda row: (str(row.get("recipe_id", "")).lower(), str(row.get("ingredient_id", "")).lower()),
    )
    return recipe_rows, ingredient_rows


def history_row(source_row: dict[str, object], history_table: str, archived_at: str) -> dict[str, object]:
    result = empty_row(history_table)
    for column in TABLE_SPECS[history_table].columns:
        if column == "archived_at":
            result[column] = archived_at
        else:
            result[column] = source_row.get(column, "")
    return result


def refresh_history_rows(
    existing_rows: list[dict[str, object]],
    history_table: str,
    source_rows: list[dict[str, object]],
    week_start: str,
    archived_at: str,
) -> list[dict[str, object]]:
    filtered = [dict(row) for row in existing_rows if str(row.get("week_start", "")) != week_start]
    additions = [history_row(row, history_table, archived_at) for row in source_rows]
    return filtered + additions


def normalize_table_rows(table_name: str, rows: list[dict[str, object]]) -> list[dict[str, object]]:
    normalized_rows: list[dict[str, object]] = []
    for row in rows:
        normalized = empty_row(table_name)
        for column in TABLE_SPECS[table_name].columns:
            normalized[column] = row.get(column, "")
        normalized_rows.append(normalized)
    return normalized_rows


def apply_plan_payload(
    payload: dict[str, object],
    workbook_path: Path = DEFAULT_WORKBOOK_PATH,
) -> dict[str, object]:
    bootstrap_workbook(workbook_path=workbook_path)

    existing_profile = read_table(workbook_path, "Profile.Preferences")
    existing_recipes = read_table(workbook_path, "Recipes.Recipes")
    existing_ingredients = read_table(workbook_path, "Recipes.RecipeIngredients")
    existing_meal_history = read_table(workbook_path, "History.MealHistory")
    existing_grocery_history = read_table(workbook_path, "History.GroceryHistory")

    profile_updates = payload.get("profile_updates")
    if profile_updates:
        profile_rows = merge_profile_updates(existing_profile, profile_updates)
        write_table(workbook_path, "Profile.Preferences", profile_rows)
    else:
        profile_rows = existing_profile

    new_recipes, new_ingredients = split_recipe_rows(payload)
    merged_recipes, merged_ingredients = merge_recipe_tables(
        existing_recipes,
        existing_ingredients,
        new_recipes,
        new_ingredients,
    )
    if new_recipes or new_ingredients:
        write_table(workbook_path, "Recipes.Recipes", merged_recipes)
        write_table(workbook_path, "Recipes.RecipeIngredients", merged_ingredients)

    raw_week_meta = payload.get("week_meta") or {}
    week_meta_rows = [raw_week_meta] if isinstance(raw_week_meta, dict) else list(raw_week_meta)
    week_meta_rows = normalize_table_rows("Current Week.WeekMeta", week_meta_rows)
    meal_plan_rows = normalize_table_rows("Current Week.MealPlan", list(payload.get("meal_plan", [])))
    grocery_rows = normalize_table_rows("Current Week.GroceryList", list(payload.get("grocery_list", [])))

    if week_meta_rows:
        write_table(workbook_path, "Current Week.WeekMeta", week_meta_rows)
    if payload.get("meal_plan") is not None:
        write_table(workbook_path, "Current Week.MealPlan", meal_plan_rows)
    if payload.get("grocery_list") is not None:
        write_table(workbook_path, "Current Week.GroceryList", grocery_rows)

    week_start = ""
    if week_meta_rows:
        week_start = str(week_meta_rows[0].get("week_start", ""))
    elif meal_plan_rows:
        week_start = str(meal_plan_rows[0].get("week_start", ""))
    elif grocery_rows:
        week_start = str(grocery_rows[0].get("week_start", ""))

    if payload.get("update_history", True) and week_start:
        archived_at = timestamp_now()
        meal_history_rows = refresh_history_rows(
            existing_meal_history,
            "History.MealHistory",
            meal_plan_rows,
            week_start,
            archived_at,
        )
        grocery_history_rows = refresh_history_rows(
            existing_grocery_history,
            "History.GroceryHistory",
            grocery_rows,
            week_start,
            archived_at,
        )
        write_table(workbook_path, "History.MealHistory", meal_history_rows)
        write_table(workbook_path, "History.GroceryHistory", grocery_history_rows)

    return {
        "status": "ok",
        "workbook_path": str(workbook_path),
        "week_start": week_start,
        "meal_count": len(meal_plan_rows),
        "grocery_count": len(grocery_rows),
        "recipe_count": len(new_recipes),
    }


def write_pricing_payload(
    payload: dict[str, object],
    workbook_path: Path = DEFAULT_WORKBOOK_PATH,
) -> dict[str, object]:
    bootstrap_workbook(workbook_path=workbook_path)
    current_rows = read_table(workbook_path, "Current Week.GroceryList")
    history_rows = read_table(workbook_path, "History.GroceryHistory")

    pricing_rows = {str(row.get("grocery_item_id", "")): dict(row) for row in payload.get("pricing_rows", [])}
    week_start = str(payload.get("week_start", ""))

    def merge(rows: list[dict[str, object]]) -> list[dict[str, object]]:
        merged_rows: list[dict[str, object]] = []
        for row in rows:
            grocery_item_id = str(row.get("grocery_item_id", ""))
            candidate = pricing_rows.get(grocery_item_id)
            if not candidate:
                merged_rows.append(dict(row))
                continue
            if week_start and str(row.get("week_start", "")) != week_start:
                merged_rows.append(dict(row))
                continue
            updated = dict(row)
            for column in TABLE_SPECS["Current Week.GroceryList"].columns:
                if column in candidate:
                    updated[column] = candidate[column]
            if "archived_at" in row:
                updated["archived_at"] = row.get("archived_at", "")
            merged_rows.append(updated)
        return merged_rows

    merged_current = merge(current_rows)
    write_table(workbook_path, "Current Week.GroceryList", merged_current)

    if history_rows:
        merged_history = merge(history_rows)
        write_table(workbook_path, "History.GroceryHistory", merged_history)
    else:
        merged_history = []

    return {
        "status": "ok",
        "workbook_path": str(workbook_path),
        "week_start": week_start,
        "updated_rows": len(pricing_rows),
        "history_rows": len(merged_history),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Read and write the weekly meal planner Numbers workbook.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    dump_parser = subparsers.add_parser("dump", help="Dump workbook tables as JSON.")
    dump_parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK_PATH)
    dump_parser.add_argument("--section", default="all")
    dump_parser.add_argument("--pretty", action="store_true")

    apply_parser = subparsers.add_parser("apply-plan", help="Apply an approved meal-plan payload.")
    apply_parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK_PATH)
    apply_parser.add_argument("--payload", type=Path, required=True)
    apply_parser.add_argument("--pretty", action="store_true")

    pricing_parser = subparsers.add_parser("write-pricing", help="Write retailer pricing rows.")
    pricing_parser.add_argument("--workbook", type=Path, default=DEFAULT_WORKBOOK_PATH)
    pricing_parser.add_argument("--payload", type=Path, required=True)
    pricing_parser.add_argument("--pretty", action="store_true")

    args = parser.parse_args()

    if args.command == "dump":
        result = dump_tables(args.workbook, args.section)
        print(json.dumps(result, indent=2 if args.pretty else None))
        return

    payload = json.loads(args.payload.read_text())
    if args.command == "apply-plan":
        result = apply_plan_payload(payload, args.workbook)
    else:
        result = write_pricing_payload(payload, args.workbook)

    print(json.dumps(result, indent=2 if args.pretty else None))


if __name__ == "__main__":
    main()
