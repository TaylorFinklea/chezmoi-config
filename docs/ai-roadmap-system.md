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

The phase execution protocol (Plan/Clarify/Build/Verify/Report) is described
separately in `docs/ai-workflows/phase-execution.md`. It is not a standalone
command — it is invoked automatically when `/process-backlog-opus` runs an
Opus item, or when substantial ad-hoc work begins.

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

Build verification command varies per project. Check the project's `CLAUDE.md`, `AGENTS.md`, or `.docs/ai/roadmap.md` for the correct command. Common patterns: `npm test`, `npm run build`, `cargo test`, `make check`.

## Execution concurrency

When working backlog items:

- **Haiku**: up to 4 items in parallel (different files, no shared state).
- **Sonnet**: up to 2 in parallel (may touch shared files — coordinate).
- **Opus**: 1 at a time (requires full codebase understanding).

After each batch, verify the build passes before starting the next.

## Phase execution protocol

Substantial work — milestone sub-items, Opus-tier backlog items, and ad-hoc
tasks involving multiple files or design decisions — follows a five-phase
protocol: Plan, Clarify, Build, Verify, Report.

The canonical definition lives in `docs/ai-workflows/phase-execution.md`.

Key integration points:

- **Backlog interaction**: Opus items are claimed (`[~]`) at Phase 1 (Plan),
  not at Phase 3 (Build). This gives other agents early visibility that
  architect-level work is in progress.
- **Handoff docs**: Phase reports update the same `current-state.md`,
  `next-steps.md`, and `decisions.md` files used by all other workflows.
- **Session boundaries**: Phase state is persisted to `.docs/ai/phases/`.
  A new session resumes from the spec file, not from chat history.
- **Scope**: Haiku and Sonnet items are exempt. They continue using the
  fast claim/build/verify flow from `/process-backlog`.

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
