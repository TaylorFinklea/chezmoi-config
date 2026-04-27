# GitHub Copilot CLI Instructions

In git repositories, treat `./.docs/ai/` as the shared AI handoff state.

Before substantive work, read:
- `./.docs/ai/roadmap.md` — milestones, Now/Next/Later items, and self-contained backlog entries
- `./.docs/ai/current-state.md` — last session summary and build status

After changes:
- Update `current-state.md` with what you did and the build status.
- Check off completed items in the roadmap; add new ones if discovered.
- Append to `decisions.md` if a non-obvious design or tooling decision was made.

## Backlog

Backlog entries in the roadmap are self-contained: scope, file paths, acceptance criteria, verification steps, and a prose tier hint ("Haiku candidate", "Sonnet — multi-file", "needs Opus to scope"). The tier hint is advice, not gating. Pick items that match your model.

Rules:
- Read referenced files before editing.
- Make a small descriptive commit per item; do not push unless the user explicitly asks.
- Do not work milestone items unless the user explicitly assigns them.
- If you fail or get stuck, leave the item `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment. Don't guess.

## Substantial work

For multi-session or multi-file work: write `.docs/ai/phases/<slug>-spec.md` before starting and `<slug>-report.md` when done. Skip this for routine changes.

Chrome DevTools MCP is managed in this chezmoi repo for Copilot CLI; when available, prefer it for browser debugging and performance investigation.
