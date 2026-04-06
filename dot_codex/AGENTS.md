# Global Agent Defaults

- After making code changes, create a small, descriptive commit by default.
- Do not push commits automatically by default; wait for the user to say when to push.
- If a repository-level `AGENTS.md` or `.cursorrules` specifies different behavior, follow the repository rules.
- If the user explicitly tells you not to commit and/or push for a task, follow that instruction.
- In git repos, use `./.docs/ai/` as the default AI handoff state directory.
- On the first substantive task in a git repo, if `./.docs/ai/` does not exist, create it.
- In non-git folders, ask before creating `./.docs/ai/`.
- At session start, read `./.docs/ai/roadmap.md`, `./.docs/ai/current-state.md`, and `./.docs/ai/next-steps.md` before doing substantive work.
- At session end, update `./.docs/ai/current-state.md`, `./.docs/ai/next-steps.md`, and `./.docs/ai/decisions.md` when a meaningful design, tooling, or scope decision was made.
- Use `./.docs/ai/handoff-template.md` as the checklist.
- Keep handoff entries concise, actionable, and focused on the next assistant.
- Treat repo-level AGENTS files as exception/override layers, not the default place to define this workflow.
- Preferred bootstrap source for a missing `./.docs/ai/` folder is the template set under `~/.codex/templates/docs-ai/`.

## Tiered Roadmap Contract

- Expect the roadmap to include a `## Backlog` section with `Haiku`, `Sonnet`, and `Opus` tiers.
- Read the roadmap owner comment before starting architectural work:
  `<!-- tier3_owner: claude|codex|copilot|unassigned -->`
- If `tier3_owner: codex`, Codex may work Opus/T3 items.
- If `tier3_owner` names another tool, Codex must not work Opus/T3 items.
- If `tier3_owner: unassigned`, Codex must not start Opus/T3 work automatically.
- Haiku and Sonnet items remain safe by default unless the roadmap item is flagged `<!-- needs-discussion -->` or `<!-- design-TBD -->`.
