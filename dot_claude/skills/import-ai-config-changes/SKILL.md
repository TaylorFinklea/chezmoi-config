---
name: import-ai-config-changes
description: Review and safely import home-directory Claude, Codex, Copilot, or generic agent skills and templates into this chezmoi repo without overwriting repo-managed AI workflow files.
user-invocable: true
disable-model-invocation: true
---

# Import AI Config Changes

Follow the canonical workflow in `../../../docs/ai-workflows/import-ai-config-changes.md`.

Claude-specific notes:

- Read `../../../docs/ai-config-import-policy.md` before evaluating imports.
- Run `./scripts/review-ai-config-imports.sh` before any import attempt.
- Do not import if the review report shows blocked repo-managed files or review-required tracked-path diffs.
- Only run `./scripts/sync-ai-configs.sh` when the review report shows safe additions only or the user explicitly approves importing just that safe subset.
