# Global Claude Code Instructions

## AI Handoff State

Cross-session continuity lives in `.docs/ai/` (git-tracked). These docs are the source of truth — not chat memory.

If the repo contains `docs/ai-roadmap-system.md`, treat it as the canonical explanation of the shared workflow system and keep Claude-specific skills aligned to it.

This repo also ships a repo-scoped `.mcp.json` with `chrome-devtools`, so Claude Code can use Chrome DevTools MCP while working in this repo.

### Session Start

1. Read (if they exist):
   - `.docs/ai/roadmap.md` — durable goals and milestones
   - `.docs/ai/current-state.md` — last session summary, blockers, build status
   - `.docs/ai/next-steps.md` — exact next actions
   - `.docs/ai/phases/` — any in-progress phase specs or recent reports
2. Check `git log --oneline -5` and `git status` to verify state matches docs.
3. If a phase spec exists without a matching report, the previous session was
   mid-protocol. Resume at the appropriate phase rather than starting fresh.
4. Ask the user what they want to work on (or pick from next-steps).

### Session End

Before signing off, update:
1. `.docs/ai/current-state.md` — session summary, changed files, blockers, build status
2. `.docs/ai/next-steps.md` — remove completed items, add new ones
3. `.docs/ai/decisions.md` — append an entry if any non-obvious design, tooling, or scope decision was made
4. If phase execution work was done, ensure the phase report in `.docs/ai/phases/` is complete.

Use `.docs/ai/handoff-template.md` as the checklist format.

### After Major Features

Update handoff docs immediately after completing a significant feature. Don't wait for session end.

### Phase Execution Protocol

For milestone sub-items, Opus-tier backlog items, and substantial ad-hoc work
(multi-file changes or design decisions), follow the autonomous phase execution
protocol in `docs/ai-workflows/phase-execution.md`.

Claude-specific tool mappings:
- **Structured prompts**: Use `AskUserQuestion` with `options` for enumerated
  choices during Clarify. Fall back to free-form `AskUserQuestion` for
  open-ended questions.
- **Progress tracking**: Use `TaskCreate` / `TaskUpdate` to track each phase
  as a task (Plan, Clarify, Build, Verify, Report).
- **Spec presentation**: Present the spec inline in the conversation. Do not
  require the user to open a file.

Haiku and Sonnet backlog items skip this protocol and use the existing
`/process-backlog` fast flow.

### Resuming After External Agent Work

If the user mentions that another AI agent (Gemini, GLM, GPT, etc.) worked on the repo while Claude was rate-limited:

1. Run `git log --oneline -10` in each affected repo to see what was committed.
2. Read changed files to understand what was done and verify quality.
3. Run the build/test command to confirm nothing is broken.
4. Update the roadmap to mark completed items and note any issues.
5. Only then proceed with new work.

Use `/handoff-prompt` to generate prompts for external agents.

### Directory Creation

- **Explicit bootstrap**: Use `/init-ai-docs` to bootstrap `.docs/ai/` and
  optionally `docs/ai-workflows/` in a new project repo.
- **Git repos**: On the first substantive task, create `.docs/ai/` if it does
  not exist. Seed it with starter templates from `~/.agents/templates/handoff/`
  (or `~/.claude/templates/handoff/` as fallback). Keep it tracked by git.
- **Non-git folders**: Ask before creating `.docs/ai/`.
- **Repo-level overrides**: If a repo's CLAUDE.md specifies a different handoff path, use that instead.

## Tiered Backlog

Maintain a `## Backlog` section in `roadmap.md` with items tiered by required model capability. This lets cheap models burn through mechanical fixes while expensive models tackle milestones.

### Tiers

| Tier | Model | Scope | Examples |
|------|-------|-------|----------|
| **Haiku** | Cheap/fast | Mechanical, 1-2 files, no judgment | Empty catch blocks, a11y labels, doc comments, linter fixes, hardcoded values |
| **Sonnet** | Mid-tier | Some architecture sense, multi-file | View refactoring, utility extraction, type safety, component extraction |
| **Opus** | Full | Design decisions, cross-cutting | Unit tests, integration tests, API design, complex refactors |

### Tier 3 ownership

Use `<!-- tier3_owner: ... -->` in the backlog section header in `roadmap.md` to declare the architect for Opus-tier work.

Valid values are `claude`, `codex`, `copilot`, and `unassigned`.

- If `tier3_owner: claude`, Claude may execute Opus-tier work.
- If `tier3_owner` names a different tool, Claude must treat Opus-tier work as off-limits by default.
- If `tier3_owner: unassigned`, no tool should start Opus-tier work automatically until the project explicitly assigns an architect.

This lets different projects be Claude-first, Codex-first, or Copilot-first while sharing the same roadmap protocol. See `~/AGENTS.md` for the non-Claude side of the contract.

### How to populate

When auditing or finishing a milestone, scan for tech debt and tag each item with a tier. Include exact file paths and line numbers. Items should be independent and low-risk — safe for a fresh agent with no session context. Use the `audit-backlog` agent (`~/.claude/agents/audit-backlog.md`) to automate this.

### How to execute

- Haiku tier: dispatch up to 4 agents in parallel (different files)
- Sonnet tier: dispatch up to 2 in parallel (may touch shared files)
- Opus tier: 1 at a time, only when `tier3_owner: claude` (otherwise Claude must not execute Opus)
- After each batch: verify the build, mark items `[x]` in the roadmap

### Standard workflow commands

Claude repos using the shared workflow system should expose:

- `/audit-backlog` — audit and append Haiku/Sonnet items
- `/process-backlog` — execute only Haiku/Sonnet items
- `/process-backlog-opus` — execute only Opus/T3 items when `tier3_owner: claude`
- `/resume-and-continue` — review recent agent work and continue only if Claude owns the next Opus phase

### Claim protocol

Before starting an item, change `- [ ]` to `- [~]` and commit the roadmap. This signals to other agents that the item is in progress. On completion, mark `- [x]`. If you fail or get stuck, revert to `- [ ]` and add a `<!-- build-failed: YYYY-MM-DD [error] -->` comment. Always skip `- [~]` items — another agent is working on them.

### Handoff to external agents

Use `/handoff-prompt` to generate self-contained prompts for Gemini/GPT/other agents when Claude is rate-limited. The prompt includes all context inline — the external agent doesn't read CLAUDE.md or roadmap.

## Common Working Style

These apply to all repos unless a repo's own CLAUDE.md overrides them.

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
