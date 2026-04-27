# Codex Home Defaults

For shared agent rules — handoff state, backlog conventions, substantial-work convention, API keys, common working style — read `~/AGENTS.md`. Apply those rules first; the notes below only cover Codex-specific behavior.

## Codex-specific notes

- After making code changes, create a small descriptive commit by default. Don't push unless the user asks.
- Use `./.docs/ai/` as the default AI handoff state directory in git repos.
- On the first substantive task in a git repo without `.docs/ai/`, create it from `~/.claude/templates/handoff/`.
- In non-git folders, ask before creating `.docs/ai/`.
- If a repo-level `AGENTS.md` exists, treat it as an override layer for that repo.
- Chrome DevTools MCP is available via the home-level Codex config in this chezmoi repo; prefer it for browser debugging.
