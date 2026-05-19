# AGENTS.md

Canonical agent instructions for this user. Applies to Claude Code, Codex, GitHub Copilot CLI, Opencode, Gemini CLI, GPT, and any other AI coding agent that operates in this user's repos. Tool-specific files (`CLAUDE.md`, `dot_codex/AGENTS.md`, `dot_copilot/copilot-instructions.md`) point here for shared rules and only override behavior unique to their harness.

## Handoff State

Cross-session continuity lives in `.docs/ai/` (git-tracked). These docs are the source of truth — not chat memory.

### Session Start

1. Read (if they exist):
   - `.docs/ai/roadmap.md` — durable goals, milestones, and active items under Now / Next / Later
   - `.docs/ai/current-state.md` — last session summary, blockers, build status
   - `.docs/ai/phases/<slug>-spec.md` or `<slug>-report.md` if the user mentions ongoing multi-session work
2. Run `git log --oneline -5` and `git status` to verify state matches docs.
3. Ask the user what they want to work on (or pick from the roadmap's Now list).

### Session End

Before signing off, update:
1. `.docs/ai/current-state.md` — last-session breadcrumb (not a journal): blockers, open questions, build status, the most recent few progress bullets
2. `.docs/ai/roadmap.md` — check off completed Now/Next items, add new ones if discovered
3. `.docs/ai/decisions.md` — append an entry if any non-obvious design, tooling, or scope decision was made
4. If substantial multi-session work is in progress, ensure the matching `<slug>-spec.md` / `<slug>-report.md` pair under `.docs/ai/phases/` reflects the current state

Use `.docs/ai/handoff-template.md` as the checklist format.

Claude Code sessions additionally get automated backstops via `dot_claude/hooks/`: a synchronous `SessionStart` hook surfaces `.docs/ai/current-state.md` freshness, and a `Stop` hook (`asyncRewake: true`) re-wakes once per session when source files changed without `current-state.md` being touched. Other agents rely on convention.

### After Major Features

Update handoff docs immediately after completing a significant feature. Don't wait for session end.

### Resuming After External Agent Work

If the user mentions that another AI agent (Codex, Opencode, Copilot, GPT, Kimi, etc.) worked on the repo while you were elsewhere:

1. `git log --oneline -10` — see what was committed
2. Read changed files to understand what was done; verify quality
3. Run the build/test command — confirm nothing is broken
4. Update the roadmap to mark completed items and note any issues
5. Only then proceed with new work

## Backlog Conventions

The roadmap may contain a `## Backlog` section with self-contained items. Each entry should include:

- **Scope** — what to do, in 1–2 sentences
- **Files** — specific paths (with line numbers when relevant)
- **Acceptance** — what "done" looks like
- **Verify** — exact command to confirm success (build, test, lint, etc.)
- **Tier hint** — prose like "Haiku candidate", "Sonnet — multi-file", "needs Opus to scope"

The tier hint is advice, not gating. Any agent can pick up any item. First agent to start it executes it. No claim ceremony, no `[~]` markers.

Claude Code ships a `/plan-backlog-item` skill that drafts entries in this shape; other tools can produce equivalent prose by hand following the same fields.

### How to work backlog items

1. Pick an unchecked item (`- [ ]`) you can execute. Match the tier hint to your model — picking work above your tier is fine if you're confident; picking below it is wasteful.
2. Read the referenced files before editing.
3. Make one commit per item (or group closely related items into one commit).
4. Verify with the entry's Verify command.
5. Mark the item `[x]` in the roadmap.
6. Do not push. The user reviews and pushes.

If you fail or get stuck, leave the item `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment.

## Substantial-Work Convention

For multi-session or multi-file work that needs continuity (typically authored by Opus): create `.docs/ai/phases/` if it doesn't exist, write a brief `<slug>-spec.md` before starting, and write a matching `<slug>-report.md` when done. No formal protocol — just enough notes to resume across sessions or hand off to another tool. Skip this for routine changes; commit messages and `current-state.md` are enough.

## Common Working Style

### Shell commands

Run one command per Bash tool call unless you genuinely need to pipe output between two commands. Don't chain unrelated commands with `&&` or `;`. Use `git -C <path>` instead of `cd <path> && git`.

### Commits and pushes

- After code changes, make a small descriptive commit by default.
- Don't push unless the user explicitly asks.

### Asking questions

When you need clarification or a decision from the user, prefer structured prompts (radio / checkbox / enumerated choices) over free-text whenever the answer space is enumerable. Most harnesses ship a structured question mechanism — Claude Code's `AskUserQuestion` with `options`, equivalents elsewhere, or at minimum a numbered list with the recommended option marked `(Recommended)`. Lead with the recommendation. Free-text answers force the user to read carefully, type a long reply, and risk ambiguity; one-tap selection is faster and clearer.

### Directory creation

- **Git repos**: On the first substantive task, create `.docs/ai/` if it doesn't exist. Seed it from `~/.claude/templates/handoff/`. Keep it tracked by git.
- **Non-git folders**: Ask before creating `.docs/ai/`.
- **Repo-level overrides**: If a repo's instruction file specifies a different handoff path, use that instead.

## Rules

- Read files before editing them.
- Don't change anything beyond what the task or backlog item describes.
- Don't add comments, docstrings, or type annotations to code you didn't change.
- Don't refactor surrounding code.
- Stop and report if you get stuck — don't guess.
- Don't push to remote.

## Repo-scoped tooling

This repo ships a `.mcp.json` with `chrome-devtools`, so tools that honor project MCP config can use Chrome DevTools MCP here.

## Chezmoi drift reconciliation

This repo is the source of truth for dotfiles managed by chezmoi. `chezmoi diff` shows where `~/` has diverged from the repo. Drift can flow either way; **default to surfacing it before resolving it.**

1. **Don't reflexively `chezmoi apply` (or `--force`).** Decide direction first:
   - Source is right, home is stale → `chezmoi apply` is correct.
   - Home is right, source is stale → hand-edit the source, then `chezmoi apply` (or `chezmoi re-add` if the file isn't templated).
   - Both have intentional changes → manual merge.
   For files the user actively hand-edits (`~/.tmux.conf`, shell rc files, editor configs), assume the home-side diff is intentional unless the user said otherwise. Show the diff and ask before clobbering.
2. **Sister-config check.** Most config surfaces have parallel files across agents (`dot_claude/settings.json.tmpl`, `dot_codex/hooks.json`, `dot_copilot/...`, `dot_config/opencode/...`). When migrating one (e.g. moshi hooks Claude → daemon in commit `8bd5bc6`), grep for the old pattern across the others before declaring the migration done. A migration that updates only one sibling is a future-incident generator.
3. **Probe canonical shapes against `mktemp -d`, never live HOME.** For moshi-hook specifically: `HOME=$(mktemp -d) moshi-hook install --target <agent>` writes the daemon's expected layout into a throwaway dir. Diff that against `dot_<agent>/hooks.json` to spot drift. Hook event names differ across agents — Claude has `PreToolUse`/`PostToolUse`; Codex does not.
4. **Verify claims before writing them.** Don't describe a file as "daemon-based" / "migrated" / "current" in a commit message or `current-state.md` without reading it first. "Force-applied the daemon-based hooks.json" is only true if the source is actually daemon-based — otherwise the breadcrumb misleads the next session.
5. **Hidden glyphs hide drift.** Powerline-style status lines embed Private Use Area characters (U+E0B0–U+E0BF) that some readers collapse in display. When two visually-identical status-line strings are supposed to mirror each other (e.g. `status-right` vs `@local_status_right`), confirm parity with `xxd`, not eyeballing.

## API Keys

### OPENAI_API_KEY

Stored in the macOS Keychain, not in source control. Set or update with:

```bash
security add-generic-password -U -a "$USER" -s OPENAI_API_KEY -w 'your-api-key-here'
```

Open a new `zsh` or `fish` shell after saving so the variable is exported automatically.

Verify:

```bash
security find-generic-password -a "$USER" -s OPENAI_API_KEY -w
```

### GITHUB_PAT_TOKEN

Stored in the macOS Keychain under service `codex-github-pat`; shell/bootstrap code exports it as `GITHUB_PAT_TOKEN`.

Set or update with:

```bash
security add-generic-password -U -a "$USER" -s codex-github-pat -w 'your-github-pat-here'
```

After saving:
- Open a new `zsh` or `fish` shell so the variable is exported automatically.
- Run `~/.local/bin/load-codex-github-pat` if you want to load it into the `launchd` environment immediately for GUI-launched tools.

Verify:

```bash
security find-generic-password -a "$USER" -s codex-github-pat -w
echo $GITHUB_PAT_TOKEN
launchctl getenv GITHUB_PAT_TOKEN
```

### LOGSEQ_DB_MCP_TOKEN

Stored in the macOS Keychain under service `logseq-db-mcp-token`; shell/bootstrap code exports it as `LOGSEQ_DB_MCP_TOKEN` for the work-only Logseq DB MCP entry in Codex and OpenCode.

Set or update with:

```bash
security add-generic-password -U -a "$USER" -s logseq-db-mcp-token -w 'your-logseq-token-here'
```

After saving:
- Open a new `zsh` or `fish` shell so the variable is exported automatically.
- Run `~/.local/bin/load-logseq-db-mcp-token` if you want to load it into the `launchd` environment immediately for GUI-launched tools.
