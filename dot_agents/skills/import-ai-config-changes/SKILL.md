---
name: import-ai-config-changes
description: Review and safely import home-directory Claude, Codex, Copilot, or generic agent skills and templates into this chezmoi repo without overwriting repo-managed AI workflow files.
disable-model-invocation: true
---

# Import AI Config Changes

Follow the canonical workflow in `../../../docs/ai-workflows/import-ai-config-changes.md`.

Generic-agent notes:

- Read `../../../docs/ai-config-import-policy.md` before evaluating imports.
- Run `./scripts/review-ai-config-imports.sh` before any import attempt.
- Only run `./scripts/sync-ai-configs.sh` when the review report shows safe additions only or the active tool has explicit user approval to import just that safe subset.
