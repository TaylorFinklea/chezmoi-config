# GitHub Copilot CLI Instructions

Before any work, read `~/AGENTS.md` and apply its rules in full. It covers:

- `.docs/ai/` handoff state (roadmap, current-state, decisions, phases)
- Backlog conventions (self-contained items, prose tier hints, no claim ceremony)
- Substantial-work convention (`spec.md` → `report.md` for multi-session work)
- API key handling (Keychain-based)
- Common working style (one command per shell call, commit defaults, etc.)

## Copilot-specific notes

- Read referenced files before editing them.
- Make a small descriptive commit per change. Don't push unless the user explicitly asks.
- Don't work milestone items unless the user explicitly assigns them.
- If you fail or get stuck, leave the item `[ ]` and add a `<!-- failed YYYY-MM-DD: [error] -->` comment. Don't guess.
- Chrome DevTools MCP is managed in this chezmoi repo for Copilot CLI; prefer it for browser debugging and performance investigation.
- Custom agents are available for artifact-first work: `spec-planner` writes durable specs, `spec-implementer` implements approved specs, and `spec-verifier` checks implementation against specs.

If `~/AGENTS.md` is unavailable or you cannot read it, ask the user before proceeding.
