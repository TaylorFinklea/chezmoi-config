# Global Claude Code Instructions

## AI Handoff State

Cross-session continuity lives in `.docs/ai/` (git-tracked). These docs are the source of truth — not chat memory.

This repo also ships a repo-scoped `.mcp.json` with `chrome-devtools`, so Claude Code can use Chrome DevTools MCP while working in this repo.

### Session Start

1. Read (if they exist):
   - `.docs/ai/roadmap.md` — durable goals, milestones, and active items under Now / Next / Later
   - `.docs/ai/current-state.md` — last session summary, blockers, build status
   - `.docs/ai/phases/` — any in-progress phase specs or recent reports
2. Check `git log --oneline -5` and `git status` to verify state matches docs.
3. Ask the user what they want to work on (or pick from the roadmap's Now list).

### Session End

Before signing off, update:
1. `.docs/ai/current-state.md` — session summary, changed files, blockers, build status
2. `.docs/ai/roadmap.md` — check off completed Now/Next items, add new ones if discovered
3. `.docs/ai/decisions.md` — append an entry if any non-obvious design, tooling, or scope decision was made
4. If substantial multi-session work was in progress, ensure the phase report in `.docs/ai/phases/` is complete.

Use `.docs/ai/handoff-template.md` as the checklist format.

### After Major Features

Update handoff docs immediately after completing a significant feature. Don't wait for session end.

### Substantial-Work Convention

For multi-session or multi-file work that needs continuity: write a brief `.docs/ai/phases/<slug>-spec.md` before starting and a `.docs/ai/phases/<slug>-report.md` when done. No formal protocol — just enough notes to resume across sessions or hand off to another tool.

For routine changes, skip this; commit messages and `current-state.md` are enough.

### Resuming After External Agent Work

If the user mentions that another AI agent (Codex, Opencode, Copilot, GPT, Kimi, etc.) worked on the repo while Claude was in another tool:

1. Run `git log --oneline -10` to see what was committed.
2. Read changed files to understand what was done and verify quality.
3. Run the build/test command to confirm nothing is broken.
4. Update the roadmap to mark completed items and note any issues.
5. Only then proceed with new work.

Use `/handoff-prompt` to generate prompts for external agents when handing work off (e.g., when rate-limited).

### Directory Creation

- **Explicit bootstrap**: Use `/init-ai-docs` to bootstrap `.docs/ai/` in a new project repo.
- **Git repos**: On the first substantive task, create `.docs/ai/` if it doesn't exist. Seed it from `~/.claude/templates/handoff/`. Keep it tracked by git.
- **Non-git folders**: Ask before creating `.docs/ai/`.
- **Repo-level overrides**: If a repo's CLAUDE.md or AGENTS.md specifies a different handoff path, use that instead.

## Backlog Conventions

The roadmap may contain a `## Backlog` section with self-contained items. Each item should include scope, file paths, acceptance criteria, verification steps, and a prose tier hint ("Haiku candidate", "Sonnet — multi-file", "needs Opus to scope").

This is single-agent-at-a-time work — no claim protocol, no `[~]` markers. First agent to pick up an item executes it; mark `[x]` when done. If you fail or get stuck, leave it `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment.

When working in Opus, use `/plan-backlog-item` to draft self-contained entries that cheaper agents (Sonnet, Haiku, GPT, Kimi) can execute later without your back-context.

## Common Working Style

These apply to all repos unless a repo's own instructions override them.

### Shell commands

Run one command per Bash tool call unless you genuinely need to pipe output between two commands. Do not chain unrelated commands with `&&` or `;`. Use `git -C <path>` instead of `cd <path> && git`.

### Commits and pushes

- After code changes, make a small descriptive commit by default.
- Do **not** push unless the user explicitly asks.

### Task tracking

Use `TaskCreate` / `TaskUpdate` to build a todo list when working on any non-trivial task. Mark tasks `in_progress` when starting and `completed` when done.

## API Keys

### OPENAI_API_KEY

Store `OPENAI_API_KEY` in the macOS Keychain instead of this repo.

Set or update it locally with:

```bash
security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w 'your-api-key-here'
```

Open a new `zsh` or `fish` shell after saving it so the variable is exported automatically.

### GITHUB_PAT_TOKEN

Store the GitHub PAT in the macOS Keychain instead of this repo. This repo expects the PAT under the Keychain service `codex-github-pat`, and shell/bootstrap code exports it as `GITHUB_PAT_TOKEN`.

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
