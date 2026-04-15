# AI Config Import Policy

This repository is the source of truth for shared AI instructions, scoped MCP configuration, workflow skills, and the tiered roadmap system. Home-directory AI tools may create or edit content outside this repo, but nothing should be copied back into managed trees until it has been staged in the inbox and classified.

## Categories

### Repo-managed

These files are edited here and distributed to machines with `chezmoi apply`. They should not be imported from home directories:

- `AGENTS.md`
- `CLAUDE.md`
- `dot_codex/AGENTS.md`
- `dot_copilot/copilot-instructions.md`
- `dot_config/opencode/opencode.json.tmpl`
- `docs/ai-roadmap-system.md`
- `docs/ai-workflows/`
- managed workflow skill directories under:
  - `dot_claude/skills/`
  - `dot_codex/skills/`
  - `dot_copilot/skills/`
  - `dot_agents/skills/`

Managed workflow skills are:

- `audit-backlog`
- `process-backlog`
- `process-backlog-opus`
- `resume-and-continue`
- `import-ai-config-changes`
- `phase-execution`

### Discovery roots

These home paths may contain useful local skills, agents, templates, commands, or modes that should be reviewed and optionally staged into the inbox:

- `~/.claude/agents/` -> `dot_claude/agents/`
- `~/.claude/skills/` -> `dot_claude/skills/`
- `~/.claude/templates/` -> `dot_claude/templates/`
- `~/.codex/skills/` -> `dot_codex/skills/`
- `~/.copilot/skills/` -> `dot_copilot/skills/`
- `~/.agents/skills/` -> `dot_agents/skills/`
- `~/.config/opencode/agent/` -> `dot_config/opencode/agent/`
- `~/.config/opencode/command/` -> `dot_config/opencode/command/`
- `~/.config/opencode/mode/` -> `dot_config/opencode/mode/`

New top-level additions are promotable only after they are staged in `.docs/ai/inbox/` with explicit metadata for:

- `scope`: `shared`, `work-only`, or `personal-only`
- `targets`: explicit tool list such as `codex,copilot,opencode`
- `kind`: `skill`, `agent`, `template`, `command`, or `mode`

### Profile-managed

These files are managed from this repo but rendered differently based on the local `ai_profile` value:

- `~/.codex/config.toml`
- `~/.copilot/mcp-config.json`
- `~/.config/opencode/opencode.json`

They should be reconciled with `chezmoi diff` / `chezmoi apply`, not imported from home directories.

## Review rules

### Safe to stage

- A new top-level artifact exists in a discovery root and does not exist in the repo projection tree.
- A new mapped example file exists in home and does not exist in the repo.

### Review required

- A tracked top-level artifact or mapped file differs between home and repo.
- A home change would add files under an existing tracked top-level directory.

### Blocked

- A repo-managed file differs between home and repo.
- A profile-managed generated file differs from what `chezmoi` would render.
- Any workflow that tries to copy local content straight into a managed tree.

## Workflow

1. Run `./scripts/review-ai-config-imports.sh`.
2. Read `.docs/ai/import-review.md`.
3. If the report contains blocked managed files, reconcile them with `chezmoi` before doing anything else.
4. Stage genuinely new additions with `./scripts/promote-ai-config-inbox.sh`.
5. Add or edit inbox metadata so `scope`, `targets`, and `kind` are explicit.
6. Promote staged content into a managed location only after the classification decision is made.
