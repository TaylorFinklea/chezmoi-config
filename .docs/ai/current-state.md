# Current State

Living snapshot of the project. Update before ending each AI session.

---

## Active Branch

`main`

## Recent Progress

- Bootstrapped `./.docs/ai/` from `~/.codex/templates/docs-ai/` for repo-local AI handoff state.
- Synced the tracked chezmoi source for `~/.codex/AGENTS.md` with the current home-directory file contents.
- Added repo documentation for the GitHub PAT bootstrap flow in `README.md`, `CLAUDE.md`, and `AGENTS.md`, including the Keychain service name `codex-github-pat`, the exported variable `GITHUB_PAT_TOKEN`, and the `launchd` loader command.
- Made the AI roadmap contract vendor-neutral so `tier3_owner` can be `claude`, `codex`, `copilot`, or `unassigned`.
- Added managed GitHub Copilot CLI instructions in `dot_copilot/copilot-instructions.md` and a Codex Opus backlog skill in `dot_codex/skills/process-backlog-opus/SKILL.md`.
- Updated `scripts/sync-ai-configs.sh` to include Copilot instructions and tolerate missing optional home files and directories during dry-run sync checks.

## Changed Files

- `.docs/ai/current-state.md`
- `.docs/ai/decisions.md`
- `.docs/ai/next-steps.md`
- `.docs/ai/roadmap.md`
- `dot_claude/skills/audit-backlog/SKILL.md`
- `dot_claude/skills/handoff-prompt/SKILL.md`
- `dot_claude/skills/process-backlog/SKILL.md`
- `dot_claude/skills/resume-and-continue/SKILL.md`
- `dot_claude/templates/handoff/roadmap.md`
- `dot_codex/AGENTS.md`
- `dot_codex/skills/process-backlog/SKILL.md`
- `dot_codex/skills/process-backlog-opus/SKILL.md`
- `dot_copilot/copilot-instructions.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `scripts/sync-ai-configs.sh`

## Blockers

- (none)

## Open Questions

- (none)

## Validation / Test Status

```
Ran ./scripts/sync-ai-configs.sh --dry-run successfully after making optional home Claude/Copilot/example paths non-fatal.
```
