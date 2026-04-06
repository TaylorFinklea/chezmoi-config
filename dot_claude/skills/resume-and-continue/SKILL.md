---
name: resume-and-continue
description: Review recent AI-agent work, verify roadmap state, and continue only if Claude is allowed to own the next architect phase.
user-invocable: true
disable-model-invocation: true
---

# Resume And Continue

Follow the canonical workflow in `../../../docs/ai-workflows/resume-and-continue.md`.

Claude-specific notes:

- Claude may continue Opus work only when `tier3_owner: claude`.
- If another tool owns Opus work, stop after reviewing state and reporting the current owner.
- Use `/handoff-prompt` only as a handoff helper; it does not change the canonical workflow rules.
