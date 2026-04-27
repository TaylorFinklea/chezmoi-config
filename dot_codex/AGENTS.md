# Global Codex Agent Defaults

- After making code changes, create a small, descriptive commit by default.
- Do not push commits automatically by default; wait for the user to say when to push.
- If a repository-level `AGENTS.md` specifies different behavior, follow the repository rules.
- If the user explicitly tells you not to commit and/or push for a task, follow that instruction.
- In git repos, use `./.docs/ai/` as the default AI handoff state directory.
- On the first substantive task in a git repo, if `./.docs/ai/` does not exist, create it.
- In non-git folders, ask before creating `./.docs/ai/`.
- At session start, read `./.docs/ai/roadmap.md` and `./.docs/ai/current-state.md` before doing substantive work.
- At session end, update `./.docs/ai/current-state.md`, the roadmap's Now/Next/Later items, and `./.docs/ai/decisions.md` when a non-obvious design, tooling, or scope decision was made.
- Use `./.docs/ai/handoff-template.md` as the checklist format.
- Keep handoff entries concise, actionable, and focused on the next assistant.
- Treat repo-level `AGENTS.md` as override layers, not the default place to define shared workflow.
- Preferred bootstrap source for a missing `./.docs/ai/` folder is `~/.claude/templates/handoff/` (template set was unified there).
- Chrome DevTools MCP is managed through the home-level Codex config template in this chezmoi repo; when available, prefer it for browser debugging and performance investigation.

## Backlog

The roadmap may include a `## Backlog` section with self-contained items. Each entry includes scope, file paths, acceptance criteria, verification steps, and a prose tier hint. Any agent can pick up any item — match your model to the tier hint, but no claim ceremony is required. First agent to start an item executes it; mark `[x]` when done. If you fail or get stuck, leave it `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment.

## Substantial work

For multi-session or multi-file work that needs continuity: write `./.docs/ai/phases/<slug>-spec.md` before starting and `<slug>-report.md` when done. No formal protocol — just enough notes to resume across sessions or hand off to another tool.
