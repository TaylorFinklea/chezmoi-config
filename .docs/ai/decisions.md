# Decision Log

Concise ADR log. Append new entries at the bottom when meaningful design, tooling, or scope decisions are made.

---

2026-04-03: Store the full `~/.codex/AGENTS.md` content in `dot_codex/AGENTS.md` so the home-level agent defaults are version controlled through chezmoi.

2026-04-03: Bootstrap `./.docs/ai/` in this repo from `~/.codex/templates/docs-ai/` and use it for ongoing assistant handoff state.

2026-04-06: Document GitHub PAT bootstrap instructions in all three root docs (`README.md`, `CLAUDE.md`, and `AGENTS.md`) and standardize on the macOS Keychain service `codex-github-pat` with the exported environment variable `GITHUB_PAT_TOKEN`.

2026-04-06: Keep the `tier3_owner` roadmap key for backward compatibility, but make the value vendor-neutral (`claude`, `codex`, `copilot`, `unassigned`) so different projects can assign a different architect without changing the protocol.

2026-04-06: Manage GitHub Copilot CLI through `~/.copilot/copilot-instructions.md` and treat it as a peer to Claude and Codex in the shared `.docs/ai` roadmap workflow.

2026-04-06: Make `docs/ai-roadmap-system.md` and `docs/ai-workflows/` the canonical source of truth for the shared backlog workflow, with per-tool skills as thin wrappers rather than four separate full copies.

2026-04-06: Normalize the shared workflow command set across Claude, Codex, Copilot, and generic agents so `/process-backlog` always means Haiku/Sonnet and `/process-backlog-opus` always means Opus/T3.

2026-04-06: Treat the four shared workflow skills as repo-managed content in this chezmoi repo and exclude them from imported home-directory skill syncs so local skill drift cannot overwrite the source-of-truth copies.

2026-04-06: Make `scripts/sync-ai-configs.sh` an additive importer instead of a mirror operation so it no longer overwrites repo-managed root docs or imports machine-specific `~/.codex/config.toml`; shared instructions flow out with `chezmoi apply`, while home-created skills/templates can be reviewed and imported intentionally.

2026-04-06: Require an explicit review step before importing home-directory AI changes by adding `docs/ai-config-import-policy.md`, `scripts/review-ai-config-imports.sh`, and the `import-ai-config-changes` workflow/skills for Claude and Codex.

2026-04-06: Allow the reviewed safe subset of home-directory AI changes to be imported only after `./scripts/sync-ai-configs.sh --dry-run` confirms the importer skips blocked repo-managed files and review-required tracked paths.

2026-04-06: Manage Chrome DevTools MCP from this repo as shared tooling: Codex gets it through the host-aware `~/.codex/config.toml` template, Copilot CLI gets it through managed `~/.copilot/mcp-config.json`, and Claude Code uses the repo-scoped `.mcp.json`.

2026-04-08: Replace hostname-based AI config selection with an explicit local `data.ai_profile` value in chezmoi so work/personal behavior is intentional and shared across Codex, Copilot, and OpenCode.

2026-04-08: Replace direct AI config imports with a review-only discovery step plus an inbox staging workflow; `scripts/sync-ai-configs.sh` no longer mutates managed trees.

2026-04-08: Manage OpenCode as a first-class user-level AI tool in this repo through `~/.config/opencode/opencode.json`, using shared `~/AGENTS.md` instructions and the same scoped MCP catalog that drives Codex and Copilot.

2026-04-09: Treat old importer-created source directories as deferred local content; keep them on disk for review, but ignore them in both chezmoi and git until they are explicitly promoted into the scoped AI catalog or deleted.

2026-04-09: Scope Codex plugins through the shared AI catalog as well; `build-web-apps@openai-curated` is personal-only because it injects `stripe`, `vercel`, and `supabase` via the plugin's own `.mcp.json`, bypassing the main Codex config template.

2026-04-09: Standardize TherapyNotes and PM work skills on a `tn-*` prefix and project that same work-only skill set into both Codex and Copilot so the work AI surfaces use the same naming convention.

2026-04-09: Manage tmux from this chezmoi repo through `dot_tmux.conf` plus a small XDG `tmux-which-key` config, preferring a lean window-first workflow, TPM plugins, popup utilities, and stable AI-TUI compatibility over a larger tmux framework.

2026-04-09: Keep tmux `automatic-rename` disabled so manually renamed windows remain stable in the top status bar, matching the interactive chooser and a window-centric workflow.

2026-04-09: Manage Karabiner from this chezmoi repo through `dot_config/karabiner/karabiner.json`, using a minimal profile with dual-role `Caps Lock`, a `Ctrl-Space` nav layer, and a `Ctrl-;` numpad layer rather than a broader keyboard remap scheme.
