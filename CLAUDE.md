# Claude Code Overrides

For shared agent rules — handoff state, backlog conventions, substantial-work convention, API keys, common working style — see [`AGENTS.md`](./AGENTS.md). Apply those rules first; the notes below only cover Claude-Code-specific behavior.

## Tool mappings

- Use `TaskCreate` / `TaskUpdate` for todo tracking on any non-trivial task. Mark `in_progress` when starting and `completed` when done.
- Use `AskUserQuestion` for structured clarifications (with `options` for enumerated choices).
- In plan mode: use `ExitPlanMode` to request plan approval. Don't ask "is the plan ok?" via `AskUserQuestion`.

## Skills available in this repo

- `/init-ai-docs` — bootstrap a slim `.docs/ai/` in a new project repo
- `/handoff-prompt` — generate a self-contained prompt to hand backlog work to another agent
- `/plan-backlog-item` — Opus drafts a self-contained backlog entry that any cheaper agent can execute

## Commands and agents

- `/spec-plan` — use `spec-planner` to write a product overview and implementation spec
- `/spec-implement` — use `spec-implementer` to execute an approved spec
- `/spec-verify` — use `spec-verifier` to check implementation against a spec

## Memory

Persistent notes for this user/project live under `~/.claude/projects/<repo>/memory/`. Build it up over time per the auto-memory directive in the system prompt.
