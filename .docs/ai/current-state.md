# Current State

Living snapshot of the project. Update before ending each AI session.

---

## Active Branch

`main`

## Recent Progress

- Made `~/.codex/config.toml` intentionally repo-managed again through the existing host-aware chezmoi split, and added Codex TUI notifications plus `osc9` delivery to both the personal and work templates.
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
- Added `docs/ai-config-import-policy.md`, a canonical `import-ai-config-changes` workflow doc, and matching Claude/Codex skills so future home-directory imports are reviewed for safety before sync.
- Added `scripts/review-ai-config-imports.sh` to classify home-directory changes as safe additions, review-required tracked diffs, blocked repo-managed conflicts, or ignored machine-local paths.
- Tightened `scripts/sync-ai-configs.sh` again so it imports only brand-new top-level additions from home skill, agent, and template trees, and skips existing tracked paths entirely.
- Added Chrome DevTools MCP as a repo-managed browser-debugging server:
  - Codex via the managed `~/.codex/config.toml` template
  - Copilot CLI via managed `~/.copilot/mcp-config.json`
  - Claude Code via the repo-scoped `.mcp.json`
- Added a repo-managed Claude Stop hook script at `dot_claude/hooks/auto-commit-on-stop.sh` and switched it to Anthropic's supported `exit 2 + stderr` blocking flow instead of invalid Stop-hook JSON.

## Changed Files

- `.chezmoitemplates/codex/personal.toml`
- `.chezmoitemplates/codex/work.toml`
- `.docs/ai/current-state.md`
- `.docs/ai/decisions.md`
- `.docs/ai/next-steps.md`
- `.docs/ai/roadmap.md`
- `.gitignore`
- `.mcp.json`
- `docs/ai-config-import-policy.md`
- `docs/ai-roadmap-system.md`
- `docs/ai-workflows/audit-backlog.md`
- `docs/ai-workflows/import-ai-config-changes.md`
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
- `dot_claude/skills/import-ai-config-changes/SKILL.md`
- `dot_claude/hooks/auto-commit-on-stop.sh`
- `dot_codex/AGENTS.md`
- `.chezmoitemplates/codex/personal.toml`
- `.chezmoitemplates/codex/work.toml`
- `dot_codex/skills/audit-backlog/SKILL.md`
- `dot_codex/skills/import-ai-config-changes/SKILL.md`
- `dot_codex/skills/process-backlog/SKILL.md`
- `dot_codex/skills/process-backlog-opus/SKILL.md`
- `dot_codex/skills/resume-and-continue/SKILL.md`
- `dot_copilot/mcp-config.json.tmpl`
- `dot_copilot/copilot-instructions.md`
- `dot_copilot/skills/audit-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog-opus/SKILL.md`
- `dot_copilot/skills/resume-and-continue/SKILL.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `scripts/review-ai-config-imports.sh`
- `scripts/sync-ai-configs.sh`

## Blockers

- (none)

## Open Questions

- (none)

## Validation / Test Status

```
Verified the host-aware Codex config split still renders from `dot_codex/private_config.toml.tmpl` into `.chezmoitemplates/codex/personal.toml` and `.chezmoitemplates/codex/work.toml`.
Confirmed both Codex templates now include `[tui]` notifications for `agent-turn-complete` and `approval-requested`, with `notification_method = "osc9"`.
Verified all four workflow skill names exist under Claude, Codex, Copilot, and generic agent skill trees.
Ran ./scripts/sync-ai-configs.sh --dry-run successfully after adding Copilot skill sync and excluding the repo-managed workflow skills from imported home skill directories.
Restored the repo after an unsafe full sync attempt, then reran ./scripts/sync-ai-configs.sh --dry-run successfully with the hardened additive-only import behavior.
Ran bash -n successfully for scripts/review-ai-config-imports.sh and scripts/sync-ai-configs.sh.
Ran ./scripts/review-ai-config-imports.sh successfully; the current report shows 55 safe additions, 3 review-required tracked path diffs, 3 blocked repo-managed instruction conflicts, and 3 ignored machine-local or managed paths.
Confirmed the importer dry run now skips repo-managed files and existing tracked paths, and only proposes additive top-level imports.
Validated `.mcp.json` and `dot_copilot/mcp-config.json.tmpl` with `jq empty`.
Rendered `dot_codex/private_config.toml.tmpl` through `chezmoi execute-template` and confirmed the `mcp_servers.chrome-devtools` entry appears in the active host config.
Verified against Anthropic's current hooks reference that `Stop` hooks should block via exit code `2` plus `stderr`, or via JSON with only `decision`/`reason`; `hookSpecificOutput` is not valid for `Stop`.
```
