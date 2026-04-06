# Process Backlog

## Purpose

Execute Haiku and Sonnet backlog items one at a time from the roadmap.

## Inputs

- `.docs/ai/roadmap.md` or `docs/ai/roadmap.md`
- repo verification/build command
- files referenced by the backlog item

## Required behavior

1. Read the roadmap and parse unchecked items from `### Haiku` and `### Sonnet`.
2. Skip claimed items `- [~]`.
3. Skip flagged items containing `<!-- needs-discussion -->` or `<!-- design-TBD -->`.
4. Default order is all Haiku items first, then Sonnet.
5. Claim the selected item by changing `- [ ]` to `- [~]` and committing the roadmap.
6. Read the referenced files before editing.
7. Implement only what the item describes.
8. Run the repo verification/build command.
9. If verification passes, mark `- [~]` to `- [x]` and commit the code plus roadmap update together.
10. If verification fails, revert the edited code files, reset the roadmap item to `- [ ]`, add a `build-failed` comment, and commit only the roadmap failure note.

## Owner rules

- `/process-backlog` never executes Opus/T3 work.
- This is true even when the active tool is the named `tier3_owner`.
- If a user wants architect-level work, the correct command is `/process-backlog-opus`.

## Verification and reporting

- Re-read the backlog after each completion because another agent may have claimed work.
- Report completed items and remaining Haiku/Sonnet counts.
- Do not push automatically.
