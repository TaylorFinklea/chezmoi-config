# GitHub Copilot CLI Instructions

In git repositories, treat `./.docs/ai/` as the shared AI handoff state.

Before substantive work, read:
- `./.docs/ai/roadmap.md`
- `./.docs/ai/current-state.md`
- `./.docs/ai/next-steps.md`

Use the roadmap owner comment as the source of truth for Opus/T3 ownership:

```markdown
<!-- tier3_owner: claude|codex|copilot|unassigned -->
```

Rules:
- If `tier3_owner: copilot`, GitHub Copilot CLI may work Opus/T3 backlog items.
- If `tier3_owner` names another tool, GitHub Copilot CLI must not work Opus/T3 items.
- If `tier3_owner: unassigned`, do not start Opus/T3 work automatically.
- Haiku and Sonnet tiers remain safe by default unless the roadmap item is flagged `<!-- needs-discussion -->` or `<!-- design-TBD -->`.
- Do not work milestone items unless the user explicitly assigns them.
- If the repo contains `docs/ai-roadmap-system.md`, treat it as the canonical workflow reference.
- Chrome DevTools MCP is managed in this chezmoi repo for Copilot CLI; when available, prefer it for browser debugging and performance investigation.
- Use the normalized workflow names when skills are available:
  - `/audit-backlog`
  - `/process-backlog`
  - `/process-backlog-opus`
  - `/resume-and-continue`
- For milestone sub-items, Opus-tier work, and multi-file ad-hoc tasks, follow the phase execution protocol in `docs/ai-workflows/phase-execution.md`. Present clarification questions as numbered lists.
- Phase specs and reports go to `.docs/ai/phases/`. Resume mid-protocol work from spec files if they exist without matching reports.
- After changes, update `current-state.md`, `next-steps.md`, and `decisions.md` when applicable.
- Make a small descriptive commit by default. Do not push unless the user explicitly asks.
