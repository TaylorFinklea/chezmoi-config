# Decision Log

Concise ADR log. Append new entries at the bottom when meaningful design, tooling, or scope decisions are made.

---

2026-04-03: Store the full `~/.codex/AGENTS.md` content in `dot_codex/AGENTS.md` so the home-level agent defaults are version controlled through chezmoi.

2026-04-03: Bootstrap `./.docs/ai/` in this repo from `~/.codex/templates/docs-ai/` and use it for ongoing assistant handoff state.

2026-04-06: Document GitHub PAT bootstrap instructions in all three root docs (`README.md`, `CLAUDE.md`, and `AGENTS.md`) and standardize on the macOS Keychain service `codex-github-pat` with the exported environment variable `GITHUB_PAT_TOKEN`.

2026-04-06: Keep the `tier3_owner` roadmap key for backward compatibility, but make the value vendor-neutral (`claude`, `codex`, `copilot`, `unassigned`) so different projects can assign a different architect without changing the protocol.

2026-04-06: Manage GitHub Copilot CLI through `~/.copilot/copilot-instructions.md` and treat it as a peer to Claude and Codex in the shared `.docs/ai` roadmap workflow.
