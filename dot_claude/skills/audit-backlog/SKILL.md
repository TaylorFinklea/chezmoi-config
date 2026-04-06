---
name: audit-backlog
description: Audit a repo for Haiku and Sonnet backlog work, preserving the current architect owner and following the shared roadmap workflow.
user-invocable: true
disable-model-invocation: true
---

# Audit Backlog

Follow the canonical workflow in `../../../docs/ai-workflows/audit-backlog.md`.

Claude-specific notes:

- Preserve the existing `tier3_owner` value unless the user explicitly asks to switch architect ownership.
- Use Claude’s stronger exploration and audit capabilities to find good Haiku and Sonnet candidates, but do not create Opus work through this command.
- Keep item descriptions concrete enough that Codex, Copilot, or another agent can execute them without extra context.
