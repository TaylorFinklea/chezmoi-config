---
description: Execute a coding task end-to-end with verification
argument-hint: "[task]"
---
Work on this task end-to-end: $ARGUMENTS

Follow the repository's instructions (CLAUDE.md / AGENTS.md). Before editing, inspect the relevant files. After changes, run the appropriate verification command (tests, lint, type-check) and report the output.

Do not commit unless I explicitly ask. Do not push.

If the work changes repo state or affects multi-session continuity, update the handoff, roadmap, and decisions docs that the repository convention calls for.
