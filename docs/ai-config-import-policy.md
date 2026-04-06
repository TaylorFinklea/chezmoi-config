# AI Config Import Policy

This repository is the source of truth for shared AI instructions, workflow skills, and the tiered roadmap system. Home-directory AI tools may create or edit content outside this repo, but imports back into the repo must be reviewed before they are accepted.

## Categories

### Repo-managed

These files are edited here and distributed to machines with `chezmoi apply`. They should not be imported from home directories:

- `AGENTS.md`
- `CLAUDE.md`
- `dot_codex/AGENTS.md`
- `dot_copilot/copilot-instructions.md`
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

### Additive imports

These home paths may contain useful new skills, agents, or templates that should be reviewed and optionally imported:

- `~/.claude/agents/` -> `dot_claude/agents/`
- `~/.claude/skills/` -> `dot_claude/skills/`
- `~/.claude/templates/` -> `dot_claude/templates/`
- `~/.codex/skills/` -> `dot_codex/skills/`
- `~/.copilot/skills/` -> `dot_copilot/skills/`
- `~/.agents/skills/` -> `dot_agents/skills/`

Additive imports are safe only when they are brand-new top-level additions in the destination tree. Changes to already tracked top-level entries require review before import.

### Machine-local

These files may legitimately differ between work and personal machines and should not be imported automatically:

- `~/.codex/config.toml`

If a machine-local file needs to be version controlled, convert it into a host-aware chezmoi template instead of mirroring one machine onto another.

## Review rules

### Safe to import

- A new top-level skill, agent, or template directory exists in home and does not exist in the repo.
- A new mapped example file exists in home and does not exist in the repo.

### Review required

- A tracked top-level skill, agent, template, or mapped file differs between home and repo.
- A home change would add files under an existing tracked top-level directory.

### Blocked

- A repo-managed file differs between home and repo.
- A machine-local file differs from what a repo copy would contain.
- A sync would require deleting tracked repo content because a home directory is missing or incomplete.

## Workflow

1. Run `./scripts/review-ai-config-imports.sh`.
2. Read `.docs/ai/import-review.md`.
3. If the report contains review-required or blocked items, do not run the importer blindly. Inspect those paths first.
4. If you want only the safe subset, keep the flagged paths untouched and run `./scripts/sync-ai-configs.sh --dry-run`.
5. If the dry run still matches expectations, run `./scripts/sync-ai-configs.sh`.
6. Review the resulting git diff before committing.
