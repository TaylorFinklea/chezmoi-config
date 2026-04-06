---
name: resume-and-continue
description: Review recent AI-agent work, verify roadmap state, and continue only if GitHub Copilot CLI is allowed to own the next architect phase.
---

# Resume And Continue

Follow the canonical workflow in `../../../docs/ai-workflows/resume-and-continue.md`.

Copilot-specific notes:

- Copilot may continue Opus work only when `tier3_owner: copilot`.
- If another tool owns Opus work, stop after reviewing state and reporting the current owner.
- This command may still review recent work and verification state even when Copilot is not the architect owner.
