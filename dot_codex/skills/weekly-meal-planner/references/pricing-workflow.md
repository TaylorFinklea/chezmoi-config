# Pricing Workflow

## Goal

Fetch current Aldi and Walmart pricing for the active `Current Week.GroceryList` rows, then write retailer-specific columns back into the workbook without silently inventing matches.

## Runtime Flow

1. Read `Profile.Preferences` and `Current Week.GroceryList` from the workbook.
2. Build search queries from `ingredient_name`, falling back to `normalized_name`.
3. Launch the Playwright scraper worker in `scripts/retailer_scrape.mjs`.
4. Scrape search results for both retailers.
5. Score the top candidates against the grocery row.
6. Write pricing results back with `numbers_sync.py write-pricing`.

## Retailer Heuristics

### Aldi

- Search URL: `https://www.aldi.us/results?q=<query>`
- Prefer product links under `/product/`.
- Extract:
  - visible product title
  - package size
  - visible price
  - product URL
  - current store label from the `Current store:` button when available

### Walmart

- Search URL: `https://www.walmart.com/search?q=<query>`
- Prefer organic product links under `/ip/` and ignore `/sp/track` sponsored redirects.
- Extract:
  - visible product title
  - package size inferred from the title or card text
  - visible `current price`
  - product URL
  - current store label from the `Pickup or delivery?` button when available

## Matching Rules

- Tokenize the grocery query and the candidate title.
- Score candidates with:
  - token overlap on the normalized title
  - a small boost when package text includes the requested unit
  - a small penalty when the title includes obvious mismatches like different proteins or flavors
- Mark the selected result as:
  - `matched` when the best score is comfortably above threshold
  - `review` when the best score is weak or too close to the runner-up
  - `unavailable` when no candidates are returned
  - `error` when scraping fails

## Store Handling

- Read store defaults from workbook preferences.
- Capture the actual store label used by each retailer scrape and write it back to the workbook.
- If the actual store label does not appear to match the stored preference, keep the result but mark the row for review in `review_flag`.
- Do not silently swap the user to a different store without reporting the actual store text.

## Totals

- Retailer totals are the sum of populated `*_line_price` cells in `Current Week.GroceryList`.
- When package-to-quantity conversion is unclear, line price falls back to the selected product price and the row may remain flagged for review.

## Failure Behavior

- Keep all grocery rows visible even when a retailer has no result.
- Never blank out existing rows because a scrape failed.
- Preserve URLs and timestamps for the last successful scrape per retailer.
- Prefer returning a partial pricing update over aborting the entire run when one row fails.
