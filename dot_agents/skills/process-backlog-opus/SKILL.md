---
name: process-backlog-opus
description: Execute Opus/T3 backlog items when the active generic agent matches the named roadmap owner, following the shared architect workflow.
disable-model-invocation: true
---

# Process Backlog Opus

Follow the canonical workflow in `../../../docs/ai-workflows/process-backlog-opus.md`.

Generic-agent notes:

- This command may run only when the active tool is the named `tier3_owner`.
- If another tool owns Opus work, stop after reporting the named owner.
