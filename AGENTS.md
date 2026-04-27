# AGENTS.md

Global agent instructions. Applies to Codex, GitHub Copilot CLI, Opencode, Gemini CLI, GPT, and any other AI coding agent. Claude Code reads `CLAUDE.md` first, but the same conventions apply.

## Handoff State

Cross-session state lives in `.docs/ai/`. Read before starting:
- `.docs/ai/roadmap.md` — milestones, active items under Now / Next / Later, and a self-contained backlog
- `.docs/ai/current-state.md` — last session summary, build status
- `.docs/ai/phases/` — any in-progress specs or recent reports for substantial multi-session work

Update before ending:
- `.docs/ai/current-state.md` — what you did, build status
- `.docs/ai/roadmap.md` — check off completed items, add new ones
- `.docs/ai/decisions.md` — append an entry if a non-obvious design or tooling decision was made

If `.docs/ai/` does not exist in a git repo, copy the templates from `~/.claude/templates/handoff/` (or use `/init-ai-docs` if running Claude Code).

This repo also ships a repo-scoped `.mcp.json` with `chrome-devtools`, so tools that honor project MCP config can use Chrome DevTools MCP here.

## Backlog Conventions

The roadmap may contain a `## Backlog` section with self-contained items. Each entry should include:

- **Scope** — what to do, in 1–2 sentences
- **Files** — specific paths (with line numbers when relevant)
- **Acceptance** — what "done" looks like
- **Verify** — exact command to confirm success (build, test, lint, etc.)
- **Tier hint** — prose like "Haiku candidate", "Sonnet — multi-file", "needs Opus to scope"

The tier hint is advice, not gating. Any agent can pick up any item. First agent to start it executes it.

### How to work backlog items

1. Pick an unchecked item (`- [ ]`) you can execute. Match the tier hint to your model — picking work above your tier is fine if you're confident; picking below it is wasteful.
2. Read the referenced files before editing.
3. Make one commit per item (or group closely related items into one commit).
4. Verify with the entry's Verify command.
5. Mark the item `[x]` in the roadmap.
6. Do not push. The user reviews and pushes.

If you fail or get stuck, leave the item `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment.

## Substantial-Work Convention

For multi-session or multi-file work that needs continuity (typically authored by Opus): write a brief `.docs/ai/phases/<slug>-spec.md` before starting and a `.docs/ai/phases/<slug>-report.md` when done. No formal protocol — just enough notes to resume across sessions or hand off to another tool. Skip this for routine changes.

## Rules

- Read files before editing them.
- Don't change anything beyond what the task or backlog item describes.
- Don't add comments, docstrings, or type annotations to code you didn't change.
- Don't refactor surrounding code.
- Stop and report if you get stuck — don't guess.
- Don't push to remote.

## API Keys

`OPENAI_API_KEY` is stored in the macOS Keychain, not in source control.

```bash
security find-generic-password -a "$USER" -s OPENAI_API_KEY -w
```

`GITHUB_PAT_TOKEN` is also stored in the macOS Keychain. This repo expects the PAT under the Keychain service `codex-github-pat`, and shell/bootstrap code exports it as `GITHUB_PAT_TOKEN`.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s codex-github-pat -w 'your-github-pat-here'
```

After saving it:
- Open a new `zsh` or `fish` shell so the variable is exported automatically.
- Run `~/.local/bin/load-codex-github-pat` if you want to load it into the `launchd` environment immediately for GUI-launched tools.

Verify with:

```bash
security find-generic-password -a "$USER" -s codex-github-pat -w
echo $GITHUB_PAT_TOKEN
launchctl getenv GITHUB_PAT_TOKEN
```
