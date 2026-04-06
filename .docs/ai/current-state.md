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
- Added canonical shared documentation in `docs/ai-roadmap-system.md` and `docs/ai-workflows/` so this repo is the source of truth for the cross-tool roadmap workflow.
- Normalized the shared workflow command set across Claude, Codex, Copilot, and generic agents:
  - `/audit-backlog`
  - `/process-backlog` for Haiku/Sonnet
  - `/process-backlog-opus` for Opus/T3
  - `/resume-and-continue`
- Added full skill parity across `dot_claude/skills/`, `dot_codex/skills/`, `dot_copilot/skills/`, and `dot_agents/skills/` using thin wrappers that point to the canonical workflow docs.
- Updated `scripts/sync-ai-configs.sh` so Copilot skills are synced and the four repo-managed workflow skills are excluded from home-directory skill imports instead of being deleted or overwritten during sync.
- Reworked `scripts/sync-ai-configs.sh` again after a real apply showed destructive behavior: it is now a conservative importer for optional home-created skills, agents, and templates, and it no longer imports repo-managed root docs or machine-specific `~/.codex/config.toml`.

## Changed Files

- `.docs/ai/current-state.md`
- `.docs/ai/decisions.md`
- `.docs/ai/next-steps.md`
- `.docs/ai/roadmap.md`
- `docs/ai-roadmap-system.md`
- `docs/ai-workflows/audit-backlog.md`
- `docs/ai-workflows/process-backlog.md`
- `docs/ai-workflows/process-backlog-opus.md`
- `docs/ai-workflows/resume-and-continue.md`
- `dot_agents/skills/audit-backlog/SKILL.md`
- `dot_agents/skills/process-backlog/SKILL.md`
- `dot_agents/skills/process-backlog-opus/SKILL.md`
- `dot_agents/skills/resume-and-continue/SKILL.md`
- `dot_claude/skills/audit-backlog/SKILL.md`
- `dot_claude/skills/process-backlog/SKILL.md`
- `dot_claude/skills/process-backlog-opus/SKILL.md`
- `dot_claude/skills/resume-and-continue/SKILL.md`
- `dot_codex/AGENTS.md`
- `dot_codex/skills/audit-backlog/SKILL.md`
- `dot_codex/skills/process-backlog/SKILL.md`
- `dot_codex/skills/process-backlog-opus/SKILL.md`
- `dot_codex/skills/resume-and-continue/SKILL.md`
- `dot_copilot/copilot-instructions.md`
- `dot_copilot/skills/audit-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog-opus/SKILL.md`
- `dot_copilot/skills/resume-and-continue/SKILL.md`
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
Verified all four workflow skill names exist under Claude, Codex, Copilot, and generic agent skill trees.
Ran ./scripts/sync-ai-configs.sh --dry-run successfully after adding Copilot skill sync and excluding the repo-managed workflow skills from imported home skill directories.
Restored the repo after an unsafe full sync attempt, then reran ./scripts/sync-ai-configs.sh --dry-run successfully with the hardened additive-only import behavior.
```
