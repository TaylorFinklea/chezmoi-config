#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import sys
from collections import defaultdict
from fractions import Fraction
from pathlib import Path


UNIT_MAP = {
    "count": "ct",
    "counts": "ct",
    "ct": "ct",
    "each": "ea",
    "ea": "ea",
    "egg": "ea",
    "eggs": "ea",
    "pound": "lb",
    "pounds": "lb",
    "lb": "lb",
    "lbs": "lb",
    "ounce": "oz",
    "ounces": "oz",
    "oz": "oz",
    "fluid ounce": "fl oz",
    "fluid ounces": "fl oz",
    "fl oz": "fl oz",
    "gallon": "gal",
    "gallons": "gal",
    "gal": "gal",
    "cup": "cup",
    "cups": "cup",
    "tablespoon": "tbsp",
    "tablespoons": "tbsp",
    "tbsp": "tbsp",
    "teaspoon": "tsp",
    "teaspoons": "tsp",
    "tsp": "tsp",
    "package": "pkg",
    "packages": "pkg",
    "pkg": "pkg",
    "can": "can",
    "cans": "can",
    "bag": "bag",
    "bags": "bag",
    "bunch": "bunch",
    "bunches": "bunch",
    "clove": "clove",
    "cloves": "clove",
    "slice": "slice",
    "slices": "slice",
}


def normalize_name(value: str) -> str:
    cleaned = value.lower().strip()
    cleaned = cleaned.replace("&", " and ")
    cleaned = re.sub(r"[^a-z0-9\s]", " ", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return cleaned


def normalize_unit(value: object) -> str:
    text = normalize_name(str(value or ""))
    return UNIT_MAP.get(text, text)


def parse_quantity(value: object) -> float | None:
    if value is None:
        return None
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return float(value)
    text = str(value).strip()
    if not text:
        return None
    try:
        return float(text)
    except ValueError:
        pass

    mixed_match = re.fullmatch(r"(\d+)\s+(\d+/\d+)", text)
    if mixed_match:
        whole = int(mixed_match.group(1))
        frac = Fraction(mixed_match.group(2))
        return float(whole + frac)

    fraction_match = re.fullmatch(r"\d+/\d+", text)
    if fraction_match:
        return float(Fraction(text))

    return None


def ingredient_id(normalized_name_value: str, unit: str, source: str) -> str:
    digest = hashlib.sha1(f"{normalized_name_value}|{unit}|{source}".encode("utf-8")).hexdigest()[:8]
    stem = re.sub(r"[^a-z0-9]+", "-", normalized_name_value).strip("-") or "item"
    suffix = f"-{unit}" if unit else ""
    return f"{stem}{suffix}-{digest}"


def split_recipe_rows(payload: dict[str, object]) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    recipes = [dict(recipe) for recipe in payload.get("recipes", [])]
    ingredients = [dict(row) for row in payload.get("recipe_ingredients", [])]

    for recipe in recipes:
        nested = recipe.pop("ingredients", None)
        if not nested:
            continue
        recipe_id = str(recipe.get("recipe_id", ""))
        for index, item in enumerate(nested, start=1):
            row = dict(item)
            row.setdefault("recipe_id", recipe_id)
            row.setdefault("ingredient_id", f"{recipe_id}-ingredient-{index}")
            ingredients.append(row)

    return recipes, ingredients


def build_recipe_lookup(
    recipes: list[dict[str, object]],
    recipe_ingredients: list[dict[str, object]],
) -> dict[str, dict[str, object]]:
    ingredients_by_recipe: dict[str, list[dict[str, object]]] = defaultdict(list)
    for ingredient in recipe_ingredients:
        ingredients_by_recipe[str(ingredient.get("recipe_id", ""))].append(dict(ingredient))

    lookup: dict[str, dict[str, object]] = {}
    for recipe in recipes:
        recipe_copy = dict(recipe)
        recipe_copy["ingredients"] = ingredients_by_recipe.get(str(recipe.get("recipe_id", "")), [])
        lookup[str(recipe_copy.get("recipe_id", ""))] = recipe_copy
    return lookup


def staple_names(payload: dict[str, object]) -> set[str]:
    result: set[str] = set()
    for staple in payload.get("staples", []):
        if isinstance(staple, dict):
            if staple.get("active") in {False, "false", "False"}:
                continue
            name = staple.get("normalized_name") or staple.get("staple_name") or ""
        else:
            name = staple
        normalized = normalize_name(str(name))
        if normalized:
            result.add(normalized)
    return result


def source_label(meal: dict[str, object]) -> str:
    day_name = str(meal.get("day_name") or meal.get("day") or "").strip()
    slot = str(meal.get("slot") or "").strip()
    recipe_name = str(meal.get("recipe_name") or meal.get("name") or meal.get("recipe_id") or "").strip()
    parts = [part for part in (day_name, slot, recipe_name) if part]
    return " / ".join(parts)


def quantity_display(quantity: float | None) -> str:
    if quantity is None:
        return ""
    if math.isclose(quantity, round(quantity), rel_tol=0, abs_tol=1e-9):
        return str(int(round(quantity)))
    return f"{quantity:.2f}".rstrip("0").rstrip(".")


def build_grocery_rows(payload: dict[str, object]) -> dict[str, object]:
    week_start = str(payload.get("week_start", ""))
    recipes, recipe_ingredients = split_recipe_rows(payload)
    recipe_lookup = build_recipe_lookup(recipes, recipe_ingredients)
    staples = staple_names(payload)
    excluded_staples: list[str] = []
    aggregations: dict[tuple[str, str, str], dict[str, object]] = {}

    for meal in payload.get("meal_plan", []):
        meal_row = dict(meal)
        inline_ingredients = [dict(item) for item in meal_row.get("ingredients", [])]
        recipe = None
        recipe_id = str(meal_row.get("recipe_id", "")).strip()
        if recipe_id:
            recipe = recipe_lookup.get(recipe_id)
        if recipe:
            base_servings = parse_quantity(recipe.get("servings")) or 1.0
            meal_servings = parse_quantity(meal_row.get("servings")) or base_servings
            factor = meal_servings / base_servings if base_servings else 1.0
            ingredients = recipe.get("ingredients", [])
            recipe_name = str(meal_row.get("recipe_name") or recipe.get("name") or recipe_id)
        else:
            factor = 1.0
            ingredients = inline_ingredients
            recipe_name = str(meal_row.get("recipe_name") or meal_row.get("name") or recipe_id or "Ad hoc meal")

        for ingredient in ingredients:
            row = dict(ingredient)
            ingredient_name = str(row.get("ingredient_name") or row.get("name") or "").strip()
            if not ingredient_name:
                continue

            normalized = normalize_name(str(row.get("normalized_name") or ingredient_name))
            if normalized in staples:
                excluded_staples.append(ingredient_name)
                continue

            unit = normalize_unit(row.get("unit", ""))
            category = str(row.get("category", "")).strip()
            prep = str(row.get("prep", "")).strip()
            notes = str(row.get("notes", "")).strip()
            if prep and prep not in notes:
                notes = prep if not notes else f"{prep}; {notes}"

            raw_quantity = parse_quantity(row.get("quantity"))
            quantity = raw_quantity * factor if raw_quantity is not None else None
            quantity_text = "" if quantity is not None else str(row.get("quantity", "")).strip()

            key = (normalized, unit, "" if quantity is not None else quantity_text)
            bucket = aggregations.get(key)
            if bucket is None:
                bucket = {
                    "grocery_item_id": ingredient_id(normalized, unit, source_label(meal_row)),
                    "week_start": week_start,
                    "ingredient_name": ingredient_name,
                    "normalized_name": normalized,
                    "total_quantity": 0.0 if quantity is not None else "",
                    "unit": unit,
                    "quantity_text": "",
                    "category": category,
                    "source_meals": set(),
                    "notes": set(),
                    "review_flag": "",
                }
                aggregations[key] = bucket

            if quantity is not None:
                bucket["total_quantity"] = float(bucket["total_quantity"] or 0) + quantity
            elif quantity_text:
                existing = str(bucket.get("quantity_text", "")).strip()
                if existing and quantity_text not in existing:
                    bucket["quantity_text"] = f"{existing}; {quantity_text}"
                else:
                    bucket["quantity_text"] = quantity_text
                bucket["review_flag"] = "quantity review"

            if category and not bucket["category"]:
                bucket["category"] = category
            if notes:
                bucket["notes"].add(notes)
            bucket["source_meals"].add(source_label(meal_row) or recipe_name)

    grocery_rows: list[dict[str, object]] = []
    for bucket in aggregations.values():
        total_quantity = bucket["total_quantity"]
        if isinstance(total_quantity, float):
            total_quantity = round(total_quantity, 2)
        grocery_rows.append(
            {
                "grocery_item_id": bucket["grocery_item_id"],
                "week_start": bucket["week_start"],
                "ingredient_name": bucket["ingredient_name"],
                "normalized_name": bucket["normalized_name"],
                "total_quantity": total_quantity,
                "unit": bucket["unit"],
                "quantity_text": bucket["quantity_text"],
                "category": bucket["category"],
                "source_meals": "; ".join(sorted(bucket["source_meals"])),
                "notes": "; ".join(sorted(bucket["notes"])),
                "aldi_status": "",
                "aldi_store": "",
                "aldi_product": "",
                "aldi_size": "",
                "aldi_unit_price": "",
                "aldi_line_price": "",
                "aldi_url": "",
                "aldi_scraped_at": "",
                "walmart_status": "",
                "walmart_store": "",
                "walmart_product": "",
                "walmart_size": "",
                "walmart_unit_price": "",
                "walmart_line_price": "",
                "walmart_url": "",
                "walmart_scraped_at": "",
                "review_flag": bucket["review_flag"],
            }
        )

    grocery_rows.sort(key=lambda row: (str(row.get("category", "")).lower(), str(row.get("ingredient_name", "")).lower()))
    return {
        "week_start": week_start,
        "grocery_list": grocery_rows,
        "excluded_staples": sorted({normalize_name(item) for item in excluded_staples}),
        "grocery_count": len(grocery_rows),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Build a grocery list from meal-plan and recipe payloads.")
    parser.add_argument("--input", type=Path, required=True, help="Path to the plan payload JSON file.")
    parser.add_argument("--output", type=Path, help="Optional path to write the result JSON.")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()

    payload = json.loads(args.input.read_text())
    result = build_grocery_rows(payload)
    serialized = json.dumps(result, indent=2 if args.pretty else None)

    if args.output:
        args.output.write_text(serialized + ("\n" if args.pretty else ""))
    else:
        print(serialized)


if __name__ == "__main__":
    main()
