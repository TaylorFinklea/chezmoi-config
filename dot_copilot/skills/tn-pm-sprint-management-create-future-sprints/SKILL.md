---
name: tn-pm-sprint-management-create-future-sprints
description: Create future TherapyNotes IT Jira sprints from the last future sprint already on the board. Use this skill when the user asks to "add future sprints", "create more IT sprints", "extend the sprint schedule", "add 2-week sprints", "create future sprint containers", or wants Jira sprint creation automated instead of done through the UI. This skill uses the local Jira sprint helper script, defaults to a dry run first, and preserves the existing IT naming convention where the sprint name is the board start date plus one day.
---

# TN PM Sprint Management Create Future Sprints

Use this skill to add future sprint containers to the TherapyNotes Information Technology Jira board without clicking through the backlog UI.

Prefer the local helper script at `/Users/tfinklea/codex/scripts/jira_create_future_sprints.py`. That script reads the last future sprint on the board, preserves its cadence, and creates the next N future sprints through the Jira Agile REST API.

## Workflow

1. Confirm the request is for future sprint creation, not sprint start or sprint close.
2. Default to board `18` unless the user names a different Jira board.
3. Default to `America/New_York`, `17:00`, and `name-offset-days=1` unless the board convention has changed.
4. Require Jira credentials from environment variables:
   - `ATLASSIAN_SITE`
   - `ATLASSIAN_EMAIL`
   - `ATLASSIAN_API_TOKEN`
5. Run the helper in dry-run mode first to show the anchor sprint and the planned future sprint sequence.
6. Report the planned sprint names and date ranges back to the user.
7. If the user already explicitly asked to create the sprints in the current turn, proceed without a second confirmation. Otherwise, ask before removing `--dry-run`.
8. Run the helper without `--dry-run` to create the sprints.
9. Report the created sprint ids, names, and dates.

## Commands

Dry run:

```bash
ATLASSIAN_SITE="https://therapynotes.atlassian.net" \
ATLASSIAN_EMAIL="you@example.com" \
ATLASSIAN_API_TOKEN="..." \
uv run python /Users/tfinklea/codex/scripts/jira_create_future_sprints.py \
  --board-id 18 \
  --count 5 \
  --dry-run
```

Create the sprints:

```bash
ATLASSIAN_SITE="https://therapynotes.atlassian.net" \
ATLASSIAN_EMAIL="you@example.com" \
ATLASSIAN_API_TOKEN="..." \
uv run python /Users/tfinklea/codex/scripts/jira_create_future_sprints.py \
  --board-id 18 \
  --count 5
```

## Expected Convention

Preserve the convention observed on the IT board:

- Sprint cadence is 14 days.
- The next sprint starts on the previous sprint end date.
- Sprint names use `IT-YYYYMMDD`.
- The `YYYYMMDD` portion is the sprint start date plus one day.

Example anchor and output:

- Anchor: `IT-20260421` covering `2026-04-20` to `2026-05-04`
- Next sprints: `IT-20260505`, `IT-20260519`, `IT-20260602`, `IT-20260616`, `IT-20260630`

## Guardrails

- Never guess the next sprint names by hand when the helper script can derive them from the board anchor.
- Never create sprints against the wrong board id.
- Never skip the dry run unless the user explicitly wants direct creation.
- Never proceed if the helper reports no future sprint anchor on the board; stop and ask the user.
- Never mutate tickets or start a sprint as part of this workflow.
- If the board naming convention changes, inspect the latest future sprint first and adjust `--name-offset-days` only when the board data proves it.

## Output Format

When reporting a dry run or creation result, include:

- Board id
- Anchor sprint name and dates
- Planned or created sprint names in order
- Start and end dates for each sprint
- Created sprint ids when available

## Related Files

- Helper script: `/Users/tfinklea/codex/scripts/jira_create_future_sprints.py`
- Planning logic: `/Users/tfinklea/codex/codex/jira_sprints.py`
