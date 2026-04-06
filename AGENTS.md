# AGENTS.md

Global agent instructions (applies to Codex, GitHub Copilot CLI, Gemini CLI, GPT, and any non-Claude AI coding agent).

## Handoff State

Cross-session state lives in `.docs/ai/` (or `docs/ai/` in older repos). Read before starting:
- `.docs/ai/roadmap.md` — milestones + tiered backlog
- `.docs/ai/current-state.md` — last session summary
- `.docs/ai/next-steps.md` — what to work on

Update before ending:
- `.docs/ai/current-state.md` — what you did, build status
- `.docs/ai/next-steps.md` — check off completed items

If the repo contains `docs/ai-roadmap-system.md`, treat it as the canonical explanation of the shared workflow system and keep tool behavior aligned to it.

## Tiered Backlog System

The roadmap contains a `## Backlog` section with items organized into three tiers:

| Tier | Who can do it | Scope |
|------|--------------|-------|
| **Haiku** | Any agent | Mechanical fixes: empty catch blocks, doc comments, a11y labels, linter issues, hardcoded values |
| **Sonnet** | Mid-tier+ agents | Refactoring, utility extraction, type safety, component extraction (multi-file, needs some judgment) |
| **Opus** | Tier 3 owner only | Unit tests, integration tests, API design, complex refactors, architecture decisions |

### Tier ownership

The backlog header may include a `tier3_owner` field:
```markdown
<!-- tier3_owner: claude|codex|copilot|unassigned -->
```

Valid values are `claude`, `codex`, `copilot`, and `unassigned`.

**If `tier3_owner` is set to a different tool, non-owner agents MUST NOT work on Tier 3 (Opus) items.** This prevents cheaper agents from making design decisions that conflict with the primary architect's vision.

**If `tier3_owner: unassigned`, no agent should start Opus work automatically.** Only lower-tier work is safe until the project explicitly assigns an architect.

To check: `grep 'tier3_owner' .docs/ai/roadmap.md` (or `docs/ai/roadmap.md`).

### What you can work on

1. **Always safe**: Haiku-tier items — they're mechanical and independent.
2. **Usually safe**: Sonnet-tier items — but read the item carefully. If it says "needs discussion" or "design TBD", skip it.
3. **Only if you're the named owner**: Opus-tier items.
4. **Never**: Milestone work (M1, M2, etc.) unless the user explicitly assigns it to you.

### How to work backlog items

1. Pick unchecked items (`- [ ]`) from your allowed tiers.
2. Read the referenced files before editing.
3. Make one commit per item (or group related items into one commit).
4. Verify the build passes after each change.
5. Mark the item `[x]` in the roadmap.
6. Do not push. The user will review and push.

### Standard workflow commands

When a repo ships workflow skills, the command meanings are fixed:

- `/audit-backlog` — audit and append Haiku/Sonnet items
- `/process-backlog` — execute only Haiku/Sonnet items
- `/process-backlog-opus` — execute only Opus/T3 items when the active tool matches `tier3_owner`
- `/resume-and-continue` — review recent agent work and continue only if the active tool owns the next Opus phase

### Claim protocol

Before starting an item, change `- [ ]` to `- [~]` and commit the roadmap. This signals to other agents that the item is in progress. On completion, mark `- [x]`. If you fail or get stuck, revert to `- [ ]` and add a `<!-- build-failed: YYYY-MM-DD [error] -->` comment. Always skip `- [~]` items — another agent is working on them.

## Rules

- Read files before editing them.
- Do not change anything beyond what the backlog item describes.
- Do not add comments, docstrings, or type annotations to code you didn't change.
- Do not refactor surrounding code.
- Stop and report if you get stuck — don't guess.
- Do not push to remote.

## API Keys

`OPENAI_API_KEY` is stored in the macOS Keychain, not in source control.

```bash
security find-generic-password -a "$USER" -s OPENAI_API_KEY -w
```

`GITHUB_PAT_TOKEN` is also stored in the macOS Keychain, not in source control. This repo expects the PAT under the Keychain service `codex-github-pat`, and shell/bootstrap code exports it as `GITHUB_PAT_TOKEN`.

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
