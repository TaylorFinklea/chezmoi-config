---
name: audit-backlog
description: Audit a repo for Haiku and Sonnet backlog work, preserving the current architect owner and following the shared roadmap workflow.
---

# Audit Backlog

Follow the canonical workflow in `../../../docs/ai-workflows/audit-backlog.md`.

Copilot-specific notes:

- Preserve the current `tier3_owner` value unless the user explicitly asks to switch architect ownership.
- Add only Haiku and Sonnet items through this command.
- Keep backlog items concrete enough for a fresh tool session to execute without additional context.
