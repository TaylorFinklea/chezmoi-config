# Decision Log

Concise ADR log. Append new entries at the bottom when meaningful design, tooling, or scope decisions are made.

---

2026-04-03: Store the full `~/.codex/AGENTS.md` content in `dot_codex/AGENTS.md` so the home-level agent defaults are version controlled through chezmoi.

2026-04-03: Bootstrap `./.docs/ai/` in this repo from `~/.codex/templates/docs-ai/` and use it for ongoing assistant handoff state.

2026-04-06: Document GitHub PAT bootstrap instructions in all three root docs (`README.md`, `CLAUDE.md`, and `AGENTS.md`) and standardize on the macOS Keychain service `codex-github-pat` with the exported environment variable `GITHUB_PAT_TOKEN`.
