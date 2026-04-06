# Process Backlog Opus

## Purpose

Execute Opus/T3 backlog items when the active tool matches the roadmap’s `tier3_owner`.

## Inputs

- `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
- `<!-- tier3_owner: ... -->`
- repo verification/build command
- files referenced by the selected Opus item

## Required behavior

1. Read the roadmap and confirm the active tool matches `tier3_owner`.
2. If the owner does not match, stop and report the named owner.
3. If `tier3_owner: unassigned`, stop and report that architect ownership must be assigned first.
4. Parse unchecked items from `### Opus`.
5. Skip claimed items `- [~]`.
6. Claim the selected item by changing `- [ ]` to `- [~]` and committing the roadmap.
7. Read all referenced files before editing.
8. Implement only the selected Opus item.
9. Run the repo verification/build command.
10. If verification passes, mark `- [~]` to `- [x]` and commit the code plus roadmap update together.
11. If verification fails, revert the edited code files, reset the roadmap item to `- [ ]`, add a `build-failed` comment, and commit only the roadmap failure note.

## Planning behavior

If Opus work is running low, the active owner may enter planning mode to propose new Opus candidates, but it must preserve the existing `tier3_owner` unless the user explicitly asks to change architect ownership.

## Reporting

- Report completed Opus items and remaining Opus count.
- Do not push automatically.
