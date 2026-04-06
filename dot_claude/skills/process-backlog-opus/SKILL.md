---
name: process-backlog-opus
description: Execute Opus/T3 backlog items when Claude is the named roadmap owner, following the shared architect workflow.
user-invocable: true
disable-model-invocation: true
---

# Process Backlog Opus

Follow the canonical workflow in `../../../docs/ai-workflows/process-backlog-opus.md`.

Claude-specific notes:

- Claude may execute this workflow only when `tier3_owner: claude`.
- If another tool owns Opus work, stop after reporting the named owner.
- Claude may plan new Opus work when the user asks or when the current Opus queue is running low, but it must preserve the current owner unless the user explicitly changes it.
