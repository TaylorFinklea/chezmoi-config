# Phase Artifacts

Lightweight specs and reports for substantial multi-session or multi-file work. No formal phase ceremony required — these are session continuity notes, not a protocol.

## When to use

- The work spans multiple sessions or touches several files
- Switching tools mid-task and need the next agent to pick up the thread
- Ad-hoc work too large for a single roadmap backlog item

For routine changes, skip this entirely — commit messages and `current-state.md` are enough.

## File naming

- `<slug>-spec.md` — what you intend to do, before starting
- `<slug>-report.md` — what actually happened, when done

A spec without a matching report means the work is in progress or was abandoned. Spec + report pairs can be deleted once the durable outcome lands in `decisions.md` or `current-state.md`.
