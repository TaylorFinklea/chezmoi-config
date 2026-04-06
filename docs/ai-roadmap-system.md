# AI Roadmap System

This repository is the source of truth for the shared AI roadmap and backlog workflow used by Claude, Codex, GitHub Copilot CLI, and generic/open-standard agent skills.

## Core contract

Every participating project uses the same handoff files:

- `.docs/ai/roadmap.md`
- `.docs/ai/current-state.md`
- `.docs/ai/next-steps.md`
- `.docs/ai/decisions.md`

The roadmap defines three backlog tiers:

- `Haiku`: mechanical, low-judgment work
- `Sonnet`: moderate refactors that need some judgment
- `Opus`: architect-level, cross-cutting work

Architect ownership is declared in the roadmap with:

```markdown
<!-- tier3_owner: claude|codex|copilot|unassigned -->
```

Rules:

- `claude`, `codex`, and `copilot` mean the named tool owns Opus/T3 work.
- `unassigned` means no tool should start Opus/T3 work automatically.
- Haiku and Sonnet can be handled by non-owner agents unless an item is explicitly flagged `<!-- needs-discussion -->` or `<!-- design-TBD -->`.

## Standard workflow commands

All supported tool surfaces should expose the same workflow set:

- `/audit-backlog`
- `/process-backlog`
- `/process-backlog-opus`
- `/resume-and-continue`

Command meanings are fixed:

- `/audit-backlog` scans a repo and appends Haiku/Sonnet backlog items.
- `/process-backlog` works only Haiku/Sonnet items.
- `/process-backlog-opus` works only Opus/T3 items and only when the active tool matches `tier3_owner`.
- `/resume-and-continue` reviews recent work, assesses roadmap state, and continues only if the active tool is allowed to own the next Opus phase.

There is no tool-specific reinterpretation of `/process-backlog`.

## Claim and completion protocol

Backlog items use three active states:

- `- [ ]` available
- `- [~]` claimed/in progress
- `- [x]` complete

Failure protocol:

- If implementation fails verification, revert the edited code files.
- Change the roadmap item back to `- [ ]`.
- Add `<!-- build-failed: YYYY-MM-DD [1-line error] -->`.
- Commit only the roadmap failure note.

Always skip `- [~]` items because another agent is already working on them.

## Tool parity model

The canonical workflow behavior lives in `docs/ai-workflows/`.

Per-tool skill files under:

- `dot_claude/skills`
- `dot_codex/skills`
- `dot_copilot/skills`
- `dot_agents/skills`

should be thin wrappers over those canonical docs. Tool-specific wrappers may describe feature differences, but they must not change the command meaning, owner rules, or claim protocol.

## Repo-managed workflow assets

This repo owns the shared workflow docs and the managed workflow skill directories for Claude, Codex, Copilot, and generic agents.

If a sync/import tool also mirrors home directories back into this repo, it must not delete these managed workflow assets when they are absent from home. Repo-managed workflow directories are protected because this repo is the maintained source of truth.
