---
name: weekly-meal-planner
description: Operate the local AI-first mealplanner app backed by SQLite, FastAPI, and a React workspace. Use when Codex needs to stage or finalize the current week’s meal plan, inspect saved recipes or profile defaults, review week history or feedback, queue Apple Reminders exports, or import Aldi, Walmart, and Sam's Club pricing into the localhost app after running local Playwright outside the container.
---

# Weekly Meal Planner

## Overview

The system of record is now the local app in `/Users/tfinklea/git/mealplanner`, not the old Numbers workbook.

Use chat as the primary authoring interface. The app persists to SQLite at `/Users/tfinklea/codex/meals/data/meals.db` and serves a React workspace at `http://localhost:8080`.

Playwright is not part of the container runtime. When pricing is needed, run Playwright locally through Codex tooling, resolve the retailer matches outside the app, then import the results into SQLite through the app API or CLI.

## Workflow

1. Ensure the app is running and healthy.
2. Read profile defaults, preference memory, saved recipes, and the current week from the app.
3. Build the AI draft in chat, reusing saved recipes when they fit and avoiding anything that conflicts with stored preference signals.
4. Create or fetch the target week, then apply the draft payload through the app API or operator CLI.
5. Let the browser workspace act as the staging ground: save scoped edits, review change history, capture feedback, and mark the week ready for chat finalization.
6. After user approval, finalize the week and regenerate the grocery list if needed.
7. Run local Aldi/Walmart/Sam's Club scraping outside the container only after the week is approved, then import the pricing results into the app.
8. After pricing import, derive a confirmed store split from matched results only, present the grouped shopping list by store, and queue export runs when the user wants Apple Reminders handoff.
9. Use the browser UI for review, scoped edits, feedback capture, grocery reconciliation, pricing comparison, and export status, but keep AI draft creation in chat or the CLI.

## Quick Start

Set the repo path once:

```bash
export MEALPLANNER_REPO="/Users/tfinklea/git/mealplanner"
```

Start or check the local app:

```bash
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" start --build --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" check --pretty
```

Read current app state:

```bash
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" profile --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" preferences --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" recipes --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" current-week --pretty
```

Create a week and apply an AI draft payload:

```bash
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" create-week --week-start 2026-03-16 --notes "Spring break" --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" apply-draft --week-id <week-id> --payload /tmp/draft.json --pretty
```

Finalize and price the current week:

```bash
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" ready-week --week-id <week-id> --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" approve-week --week-id <week-id> --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" import-pricing --week-id <week-id> --payload /tmp/pricing.json --pretty
```

Review staged history, remember feedback, and run exports:

```bash
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" week-changes --week-id <week-id> --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" week-feedback --week-id <week-id> --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" save-week-feedback --week-id <week-id> --payload /tmp/feedback.json --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" create-export --week-id <week-id> --export-type shopping_split --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" run-reminders-export --export-id <export-id> --replace-lists --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" save-preferences --payload /tmp/preferences.json --pretty
python3 "$MEALPLANNER_REPO/scripts/mealplanner_cli.py" score-meal --payload /tmp/candidate.json --pretty
```

## Planning Rules

- Read the profile settings and staples first; treat prompt details as overrides, not replacements.
- Read `/api/preferences` before proposing meals, and update it whenever the user gives explicit feedback about liking, disliking, avoiding, or preferring a meal, ingredient, cuisine, brand, or planning pattern.
- Default week start is Monday and default slots are `breakfast`, `lunch`, `dinner`, `snack`.
- Keep pantry handling limited to staple exclusions; do not subtract quantity-based pantry inventory.
- Prefer saved recipes when they fit, but allow new AI meals and ad hoc meals with inline ingredients.
- Treat the browser UI as the main staging workspace for reviewing and editing saved state, seeing change history, capturing feedback, and queueing exports, but not for direct AI generation.
- Do not import pricing on a draft week.
- Do not assume the container can browse retailers. All Playwright work must happen outside the app runtime.
- Treat `review` and `unavailable` pricing rows as non-recommendations. They can inform discussion, but they must not drive the best-store split or cart-building workflow.
- Use Sam's Club selectively for bulk or strong-brand wins, not as a default full-store shopping plan.
- Apple Reminders export is host-side only. Queue exports in the app, then execute them with the CLI or by acting directly from chat.
- Do not use the legacy Numbers scripts unless the user explicitly asks for legacy export or workbook work.

## Data Flow

### 1. App Health And Defaults

- Run `scripts/mealplanner_cli.py start` or `check` when needed.
- Use the CLI or `/api/profile`, `/api/preferences`, `/api/recipes`, and `/api/weeks/current` to inspect state.
- Treat `preference_signals` as durable recommendation memory. If the user says "don't suggest that again" or explains why a dish failed, save it there instead of relying on turn memory.

### 2. Build The Draft

- Collect the user’s goals for the coming week: constraints, variety, leftovers, social plans, and any overrides.
- Use the deterministic meal score endpoint as a baseline check when a candidate is close, ambiguous, or related to prior feedback.
- Build a `draft-from-ai` payload with:
  - `profile_updates`
  - `recipes`
  - `meal_plan`
  - `week_notes`
- When a meal is ad hoc and not worth saving as a reusable recipe, keep its ingredient rows inline on the meal payload.

### 3. Generate Grocery Rows

- The app regenerates grocery rows automatically from the saved meals.
- Keep staple exclusions explicit and visible in the returned output.
- If ingredient quantities or units are ambiguous, keep the row and surface the `review_flag`; do not silently drop it.

### 4. Stage And Persist The Week

- Save staged edits before final approval so the browser state stays authoritative.
- Use:
  - `POST /api/weeks`
  - `POST /api/weeks/{id}/draft-from-ai`
  - `PUT /api/weeks/{id}/meals`
  - `GET /api/weeks/{id}/changes`
  - `POST /api/weeks/{id}/ready-for-ai`
  - `GET/POST /api/weeks/{id}/feedback`
  - `POST /api/weeks/{id}/approve`
  - `POST /api/weeks/{id}/grocery/regenerate`

### 5. Price The Current Grocery List

- Use local Playwright tooling to gather current retailer data outside the app.
- Import the resolved results with `POST /api/weeks/{id}/pricing/import` or the CLI `import-pricing` command.
- Keep ambiguous retailer matches as `review` instead of pretending the match is final.
- Include Sam's Club when the week has known warehouse-club items, bulk staples, or durable brand-specific wins.

### 6. Turn Pricing Into A Shopping Plan

- Build the recommended split from `matched` rows only.
- Report raw retailer totals separately from the confirmed recommended split.
- Group the shopping list by winning store with quantity, unit, price, and listing title when available.
- Keep any `review` or `unavailable` items in a manual-review section instead of assigning them to a winner store.
- If the user wants cart help, use Playwright to clean or build the Walmart and Sam's Club carts from the confirmed winner list.
- Do not silently leave Aldi winners in the Walmart cart or vice versa.
- If a retailer blocks automation or presents a bot challenge, stop and ask the user to clear it locally rather than guessing or working around it.

### 7. Queue And Execute Exports

- Queue `meal_plan` or `shopping_split` exports inside the app first.
- Read export status with `GET /api/weeks/{id}/exports` or `GET /api/exports/{id}`.
- For Apple Reminders handoff, execute `scripts/mealplanner_cli.py run-reminders-export --export-id <id> --replace-lists`.
- Treat export runs as durable history. Do not silently rerun or overwrite a finished export without saying so.

## Output Expectations

- Summarize the proposed week in day/slot order before saving.
- Summarize grocery rows grouped by category or department when helpful.
- When pricing runs, report raw retailer totals, the confirmed recommended split, and any unmatched or ambiguous lines.
- When the user asks for a shopping plan, present a store-grouped list that they can shop directly.
- When the week is being staged, call out the current stage, the latest saved change batch, and whether the week is ready for chat finalization.
- When the user asks for cart help, report which retailer carts were updated and which items, if any, still need manual cleanup.
- When exports are involved, report which export was queued or completed, the destination list(s), and whether host-side automation succeeded or failed.
- Use the app database as the persisted source of truth; temporary JSON files are only intermediate artifacts.

## Resources

- `/Users/tfinklea/git/mealplanner/scripts/mealplanner_cli.py`: operator wrapper for the local app.
- `/Users/tfinklea/git/mealplanner/app/services/preferences.py`: durable taste memory and deterministic scoring baseline.
- `/Users/tfinklea/git/mealplanner/app/services/grocery.py`: grocery aggregation and staple exclusion logic.
- `/Users/tfinklea/git/mealplanner/app/services/pricing.py`: pricing import and persistence logic.
- `/Users/tfinklea/git/mealplanner/README.md`: repo-level app workflow and API summary.

Legacy workbook scripts remain in this skill folder only for later export work. They are not part of the default path anymore.
