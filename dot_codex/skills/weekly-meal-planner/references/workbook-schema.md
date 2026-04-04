# Workbook Schema

Canonical workbook path: `/Users/tfinklea/codex/meals/weekly-meal-planner.numbers`

## Sheets And Tables

### `Profile`

`Preferences`

| Column | Purpose |
| --- | --- |
| `key` | Stable preference key |
| `value` | Stored value |
| `updated_at` | ISO timestamp of the latest update |

Default keys:

- `household_name`
- `week_start_day`
- `default_slots`
- `dietary_constraints`
- `cuisine_preferences`
- `budget_notes`
- `timezone`
- `currency`
- `aldi_store_name`
- `aldi_store_zip`
- `aldi_store_id`
- `walmart_store_name`
- `walmart_store_zip`
- `walmart_store_id`

`Staples`

| Column | Purpose |
| --- | --- |
| `staple_name` | Human-readable staple item |
| `normalized_name` | Lowercase normalized match key |
| `notes` | Optional qualifier |
| `active` | `true` / `false` flag |

### `Recipes`

`Recipes`

| Column | Purpose |
| --- | --- |
| `recipe_id` | Stable recipe identifier |
| `name` | Display name |
| `meal_type` | Breakfast, lunch, dinner, snack, or mixed |
| `cuisine` | Cuisine/theme |
| `servings` | Base serving count |
| `prep_minutes` | Prep time |
| `cook_minutes` | Cook time |
| `tags` | Comma-separated tags |
| `instructions_summary` | Short summary, not full recipe prose |
| `favorite` | `true` / `false` |
| `source` | `saved`, `generated`, `manual`, etc. |
| `notes` | Optional notes |
| `last_used` | ISO date or timestamp |

`RecipeIngredients`

| Column | Purpose |
| --- | --- |
| `recipe_id` | Parent recipe identifier |
| `ingredient_id` | Stable ingredient row identifier |
| `ingredient_name` | Human-readable ingredient |
| `normalized_name` | Lowercase normalized match key |
| `quantity` | Numeric quantity when known |
| `unit` | Canonical unit |
| `prep` | Prep detail, for example `diced` |
| `category` | Grocery grouping |
| `notes` | Optional detail |

### `Current Week`

`WeekMeta`

| Column | Purpose |
| --- | --- |
| `week_start` | ISO date for Monday |
| `week_end` | ISO date for Sunday |
| `status` | `draft`, `approved`, `priced`, etc. |
| `generated_at` | ISO timestamp |
| `updated_at` | ISO timestamp |
| `notes` | Optional week-level notes |

`MealPlan`

| Column | Purpose |
| --- | --- |
| `week_start` | ISO date |
| `day_name` | Monday-Sunday |
| `meal_date` | ISO date |
| `slot` | Breakfast, lunch, dinner, snack |
| `recipe_id` | Saved recipe id when available |
| `recipe_name` | Display name |
| `servings` | Intended servings |
| `source` | `saved`, `generated`, `manual` |
| `approved` | `true` / `false` |
| `notes` | Optional notes |

`GroceryList`

| Column | Purpose |
| --- | --- |
| `grocery_item_id` | Stable grocery row identifier |
| `week_start` | ISO date |
| `ingredient_name` | Display ingredient |
| `normalized_name` | Lowercase normalized match key |
| `total_quantity` | Aggregated numeric quantity |
| `unit` | Canonical unit |
| `quantity_text` | Text fallback for ambiguous quantities |
| `category` | Grocery grouping |
| `source_meals` | Semicolon-separated meal references |
| `notes` | Optional notes |
| `aldi_status` | `matched`, `review`, `unavailable`, `error` |
| `aldi_store` | Store label used by the scrape |
| `aldi_product` | Selected product title |
| `aldi_size` | Package size |
| `aldi_unit_price` | Product price |
| `aldi_line_price` | Estimated line price |
| `aldi_url` | Product URL |
| `aldi_scraped_at` | ISO timestamp |
| `walmart_status` | `matched`, `review`, `unavailable`, `error` |
| `walmart_store` | Store label used by the scrape |
| `walmart_product` | Selected product title |
| `walmart_size` | Package size |
| `walmart_unit_price` | Product price |
| `walmart_line_price` | Estimated line price |
| `walmart_url` | Product URL |
| `walmart_scraped_at` | ISO timestamp |
| `review_flag` | Manual review note |

### `History`

`MealHistory`

Same columns as `MealPlan`, plus:

| Column | Purpose |
| --- | --- |
| `archived_at` | ISO timestamp of the history refresh |

`GroceryHistory`

Same columns as `GroceryList`, plus:

| Column | Purpose |
| --- | --- |
| `archived_at` | ISO timestamp of the history refresh |

## Payload Shapes

### `numbers_sync.py apply-plan`

```json
{
  "profile_updates": {
    "dietary_constraints": "high protein",
    "budget_notes": "keep dinners under $25"
  },
  "recipes": [],
  "recipe_ingredients": [],
  "week_meta": {
    "week_start": "2026-03-16",
    "week_end": "2026-03-22",
    "status": "approved",
    "generated_at": "2026-03-12T14:00:00-05:00",
    "updated_at": "2026-03-12T14:15:00-05:00",
    "notes": ""
  },
  "meal_plan": [],
  "grocery_list": [],
  "update_history": true
}
```

### `numbers_sync.py write-pricing`

```json
{
  "week_start": "2026-03-16",
  "pricing_rows": [
    {
      "grocery_item_id": "milk-1-gal-abc123",
      "aldi_status": "matched",
      "aldi_store": "66111, Kansas City",
      "aldi_product": "1% Milk, 1 gal",
      "aldi_size": "1 gal",
      "aldi_unit_price": 3.95,
      "aldi_line_price": 3.95,
      "aldi_url": "https://www.aldi.us/product/...",
      "aldi_scraped_at": "2026-03-12T14:22:00-05:00",
      "walmart_status": "matched",
      "walmart_store": "Basehor, 66007 • Bonner Springs Supercenter",
      "walmart_product": "Great Value 1% Low-Fat Milk, Gallon, 128 fl oz",
      "walmart_size": "128 fl oz",
      "walmart_unit_price": 3.56,
      "walmart_line_price": 3.56,
      "walmart_url": "https://www.walmart.com/ip/...",
      "walmart_scraped_at": "2026-03-12T14:23:00-05:00",
      "review_flag": ""
    }
  ]
}
```
