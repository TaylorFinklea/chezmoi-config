#!/usr/bin/env python3
from __future__ import annotations

from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS_DIR = SKILL_ROOT / "assets"
DEFAULT_TEMPLATE_PATH = ASSETS_DIR / "weekly-meal-planner-template.numbers"
DEFAULT_WORKBOOK_DIR = Path("/Users/tfinklea/codex/meals")
DEFAULT_WORKBOOK_PATH = DEFAULT_WORKBOOK_DIR / "weekly-meal-planner.numbers"
DEFAULT_WEEK_START = "Monday"
DAYS_OF_WEEK = (
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
)
DEFAULT_SLOTS = ("breakfast", "lunch", "dinner", "snack")


@dataclass(frozen=True)
class TableSpec:
    sheet: str
    table: str
    columns: tuple[str, ...]
    position: tuple[int, int]
    header_rows: int = 1


PROFILE_DEFAULTS = OrderedDict(
    [
        ("household_name", ""),
        ("week_start_day", DEFAULT_WEEK_START),
        ("default_slots", ",".join(DEFAULT_SLOTS)),
        ("dietary_constraints", ""),
        ("cuisine_preferences", ""),
        ("budget_notes", ""),
        ("timezone", "America/Chicago"),
        ("currency", "USD"),
        ("aldi_store_name", ""),
        ("aldi_store_zip", ""),
        ("aldi_store_id", ""),
        ("walmart_store_name", ""),
        ("walmart_store_zip", ""),
        ("walmart_store_id", ""),
    ]
)

DEFAULT_STAPLES = (
    {"staple_name": "Olive oil", "normalized_name": "olive oil", "notes": "", "active": True},
    {"staple_name": "Kosher salt", "normalized_name": "kosher salt", "notes": "", "active": True},
    {"staple_name": "Black pepper", "normalized_name": "black pepper", "notes": "", "active": True},
)

TABLE_SPECS: "OrderedDict[str, TableSpec]" = OrderedDict(
    [
        (
            "Profile.Preferences",
            TableSpec(
                sheet="Profile",
                table="Preferences",
                columns=("key", "value", "updated_at"),
                position=(80, 80),
            ),
        ),
        (
            "Profile.Staples",
            TableSpec(
                sheet="Profile",
                table="Staples",
                columns=("staple_name", "normalized_name", "notes", "active"),
                position=(80, 320),
            ),
        ),
        (
            "Recipes.Recipes",
            TableSpec(
                sheet="Recipes",
                table="Recipes",
                columns=(
                    "recipe_id",
                    "name",
                    "meal_type",
                    "cuisine",
                    "servings",
                    "prep_minutes",
                    "cook_minutes",
                    "tags",
                    "instructions_summary",
                    "favorite",
                    "source",
                    "notes",
                    "last_used",
                ),
                position=(80, 80),
            ),
        ),
        (
            "Recipes.RecipeIngredients",
            TableSpec(
                sheet="Recipes",
                table="RecipeIngredients",
                columns=(
                    "recipe_id",
                    "ingredient_id",
                    "ingredient_name",
                    "normalized_name",
                    "quantity",
                    "unit",
                    "prep",
                    "category",
                    "notes",
                ),
                position=(80, 360),
            ),
        ),
        (
            "Current Week.WeekMeta",
            TableSpec(
                sheet="Current Week",
                table="WeekMeta",
                columns=("week_start", "week_end", "status", "generated_at", "updated_at", "notes"),
                position=(80, 80),
            ),
        ),
        (
            "Current Week.MealPlan",
            TableSpec(
                sheet="Current Week",
                table="MealPlan",
                columns=(
                    "week_start",
                    "day_name",
                    "meal_date",
                    "slot",
                    "recipe_id",
                    "recipe_name",
                    "servings",
                    "source",
                    "approved",
                    "notes",
                ),
                position=(80, 240),
            ),
        ),
        (
            "Current Week.GroceryList",
            TableSpec(
                sheet="Current Week",
                table="GroceryList",
                columns=(
                    "grocery_item_id",
                    "week_start",
                    "ingredient_name",
                    "normalized_name",
                    "total_quantity",
                    "unit",
                    "quantity_text",
                    "category",
                    "source_meals",
                    "notes",
                    "aldi_status",
                    "aldi_store",
                    "aldi_product",
                    "aldi_size",
                    "aldi_unit_price",
                    "aldi_line_price",
                    "aldi_url",
                    "aldi_scraped_at",
                    "walmart_status",
                    "walmart_store",
                    "walmart_product",
                    "walmart_size",
                    "walmart_unit_price",
                    "walmart_line_price",
                    "walmart_url",
                    "walmart_scraped_at",
                    "review_flag",
                ),
                position=(80, 600),
            ),
        ),
        (
            "History.MealHistory",
            TableSpec(
                sheet="History",
                table="MealHistory",
                columns=(
                    "week_start",
                    "day_name",
                    "meal_date",
                    "slot",
                    "recipe_id",
                    "recipe_name",
                    "servings",
                    "source",
                    "approved",
                    "notes",
                    "archived_at",
                ),
                position=(80, 80),
            ),
        ),
        (
            "History.GroceryHistory",
            TableSpec(
                sheet="History",
                table="GroceryHistory",
                columns=(
                    "grocery_item_id",
                    "week_start",
                    "ingredient_name",
                    "normalized_name",
                    "total_quantity",
                    "unit",
                    "quantity_text",
                    "category",
                    "source_meals",
                    "notes",
                    "aldi_status",
                    "aldi_store",
                    "aldi_product",
                    "aldi_size",
                    "aldi_unit_price",
                    "aldi_line_price",
                    "aldi_url",
                    "aldi_scraped_at",
                    "walmart_status",
                    "walmart_store",
                    "walmart_product",
                    "walmart_size",
                    "walmart_unit_price",
                    "walmart_line_price",
                    "walmart_url",
                    "walmart_scraped_at",
                    "review_flag",
                    "archived_at",
                ),
                position=(80, 360),
            ),
        ),
    ]
)

SECTION_TABLES = {
    "profile": ("Profile.Preferences", "Profile.Staples"),
    "recipes": ("Recipes.Recipes", "Recipes.RecipeIngredients"),
    "current-week": ("Current Week.WeekMeta", "Current Week.MealPlan", "Current Week.GroceryList"),
    "history": ("History.MealHistory", "History.GroceryHistory"),
    "all": tuple(TABLE_SPECS.keys()),
}

PRIMARY_KEYS = {
    "Profile.Preferences": ("key",),
    "Profile.Staples": ("normalized_name",),
    "Recipes.Recipes": ("recipe_id",),
    "Recipes.RecipeIngredients": ("recipe_id", "ingredient_id"),
    "Current Week.WeekMeta": ("week_start",),
    "Current Week.MealPlan": ("week_start", "day_name", "slot"),
    "Current Week.GroceryList": ("week_start", "grocery_item_id"),
    "History.MealHistory": ("week_start", "day_name", "slot"),
    "History.GroceryHistory": ("week_start", "grocery_item_id"),
}

NUMERIC_COLUMNS = {
    "Recipes.Recipes": {"servings", "prep_minutes", "cook_minutes"},
    "Recipes.RecipeIngredients": {"quantity"},
    "Current Week.MealPlan": {"servings"},
    "Current Week.GroceryList": {"total_quantity", "aldi_unit_price", "aldi_line_price", "walmart_unit_price", "walmart_line_price"},
    "History.MealHistory": {"servings"},
    "History.GroceryHistory": {"total_quantity", "aldi_unit_price", "aldi_line_price", "walmart_unit_price", "walmart_line_price"},
}

BOOLEAN_COLUMNS = {
    "Profile.Staples": {"active"},
    "Recipes.Recipes": {"favorite"},
    "Current Week.MealPlan": {"approved"},
    "History.MealHistory": {"approved"},
}

HISTORY_MIRRORS = {
    "History.MealHistory": "Current Week.MealPlan",
    "History.GroceryHistory": "Current Week.GroceryList",
}


def default_rows(table_key: str) -> list[dict[str, object]]:
    if table_key == "Profile.Preferences":
        return [
            {"key": key, "value": value, "updated_at": ""}
            for key, value in PROFILE_DEFAULTS.items()
        ]
    if table_key == "Profile.Staples":
        return list(DEFAULT_STAPLES)
    return []


def table_keys_for_section(section: str) -> tuple[str, ...]:
    normalized = section.lower()
    if normalized not in SECTION_TABLES:
        raise KeyError(f"Unknown section: {section}")
    return SECTION_TABLES[normalized]


def table_key(sheet: str, table: str) -> str:
    return f"{sheet}.{table}"


def coerce_cell_value(table_name: str, column: str, value: str) -> object:
    if value == "":
        return ""
    if column in BOOLEAN_COLUMNS.get(table_name, set()):
        lowered = value.lower()
        if lowered in {"true", "false"}:
            return lowered == "true"
        if lowered in {"1", "1.0"}:
            return True
        if lowered in {"0", "0.0"}:
            return False
    if column in NUMERIC_COLUMNS.get(table_name, set()):
        try:
            if "." in value:
                return float(value)
            return int(value)
        except ValueError:
            return value
    return value


def empty_row(table_name: str) -> dict[str, object]:
    return {column: "" for column in TABLE_SPECS[table_name].columns}


def column_format(table_name: str, column: str) -> str:
    if column in NUMERIC_COLUMNS.get(table_name, set()):
        return "number"
    return "text"
