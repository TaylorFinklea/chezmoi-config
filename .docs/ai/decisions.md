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

2026-04-10: Configure TmuxAI as a repo-managed terminal assistant surface with two profiles: `codex` via the OpenAI provider and `copilot` via TmuxAI's native `github-copilot` provider. Launch both from tmux popups rooted in the current pane directory.

2026-04-10: Set the managed TmuxAI defaults to `gpt-5.4` for the OpenAI-backed Codex profile and `claude-sonnet-4.6` for the GitHub Copilot profile.

2026-04-10: Omit `api_key` from the managed TmuxAI Copilot profile and rely on the authenticated `copilot` CLI session, per the upstream TmuxAI guidance for the `github-copilot` provider.

2026-04-09: Manage tmux from this chezmoi repo through `dot_tmux.conf` plus a small XDG `tmux-which-key` config, preferring a lean window-first workflow, TPM plugins, popup utilities, and stable AI-TUI compatibility over a larger tmux framework.

2026-04-09: Keep tmux `automatic-rename` disabled so manually renamed windows remain stable in the top status bar, matching the interactive chooser and a window-centric workflow.

2026-04-09: Use direct `Alt-h` / `Alt-l` tmux bindings for previous/next window cycling, keeping `C-a h/j/k/l` as the safe pane-navigation fallback instead of overloading more plain `Ctrl` combinations.

2026-04-13: Keep the tmux previous/next window bindings on `Meta-h` / `Meta-l`, but remap Ghostty `Cmd-h` / `Cmd-l` to emit those sequences so AeroSpace can own the desktop-level left/right shortcuts without changing tmux itself.

2026-04-09: Manage Karabiner from this chezmoi repo through `dot_config/karabiner/karabiner.json`, using a minimal profile with dual-role `Caps Lock`, a `Ctrl-Space` nav layer, and a `Ctrl-;` numpad layer rather than a broader keyboard remap scheme.

2026-04-10: Add personal-only Supabase, Fly.io, and Railway MCP entries through the shared AI catalog, but name the Supabase server `supabase-personal` so the managed Codex config does not collide with the plugin-bundled `supabase` server from `build-web-apps@openai-curated`.

2026-04-10: Manage the Espanso base match file from this repo for work machines only; personal machines should ignore `Library/Application Support/espanso/match/base.yml` so text expansions can diverge by profile.

2026-04-10: Keep personal Espanso snippets in separate profile-scoped files under the same match directory rather than branching one shared `base.yml`; personal machines now get `personal-email.yml` while work machines ignore it.

2026-04-15: Add an autonomous phase execution protocol (Plan/Clarify/Build/Verify/Report) as a canonical workflow doc at `docs/ai-workflows/phase-execution.md`. The protocol applies to milestone sub-items, Opus-tier backlog items, and substantial ad-hoc work; Haiku/Sonnet items remain on the fast `/process-backlog` flow. Phase specs and reports persist to `.docs/ai/phases/` so sessions can resume mid-protocol. Clarifications use structured-first prompts (enumerated options, batched 2–4). The protocol is tool-agnostic with per-tool skill wrappers for Claude, Codex, Copilot, and generic agents.

2026-04-16: Manage the Spacelift CLI on work machines through the official Homebrew tap `spacelift-io/spacelift` plus the `spacectl` formula in `scripts/install-homebrew-work.sh`, instead of relying on an unqualified `spacelift` package name that Homebrew does not provide.

2026-04-18: Make tmux explicitly start Fish by setting `default-shell` to `/opt/homebrew/bin/fish` and `default-command` to `/opt/homebrew/bin/fish -l`, so fresh tmux sessions, windows, splits, and managed TmuxAI popups all use the same shell instead of inheriting zsh from the parent environment.

2026-04-21: Disable the user-scope Claude Code Vercel plugin instead of uninstalling or deleting its config. This preserves the installed `vercel-plugin@vercel-vercel-plugin` cache and metadata, while preventing its hooks and skill injections from influencing unrelated Claude Code sessions.

2026-04-24: Keep tmux window navigation and reordering on the existing `Meta-h/l` and `Meta-H/L` bindings, and have Ghostty translate `Cmd-h/l` plus `Cmd-Shift-h/l` into those sequences. This preserves AeroSpace ownership of real Alt-based desktop movement while making tmux window order controllable from the same Cmd chord family.

2026-04-26: Slim the AI-agent overlay layer. Audit of artifacts across 7 active repos showed the journal layer (current-state.md, phase spec→report pairs) is alive while the protocol layer (tier3_owner claim markers, `[~]` claim protocol, parallel-tier dispatch via process-backlog/process-backlog-opus/resume-and-continue, cross-tool config sync via import-ai-config-changes, formal 5-phase Plan/Clarify/Build/Verify/Report ceremony, AGENTS.md boilerplate mirroring CLAUDE.md without divergence) was unused — actual workflow is one agent per session, switching tools across windows, never parallel orchestration. Deleted six workflow skills across `dot_claude/`, `dot_copilot/`, `dot_agents/`, plus `docs/ai-workflows/`, `docs/ai-roadmap-system.md`, `docs/ai-config-import-policy.md`, the three import scripts, `dot_agents/templates/`, and `.docs/ai/inbox/` + `.docs/ai/next-steps.md`. Reverses the M1 normalization decisions of 2026-04-06 (workflow command normalization, four-tool skill parity, importer/inbox classification).

2026-04-26: Adopt `AGENTS.md` as the canonical instruction file; `CLAUDE.md` and `copilot-instructions.md` become thin pointers plus tool-specific overrides only. Rationale: AGENTS.md is the cross-tool standard (Codex originator; Opencode, Cursor, Aider, Gemini CLI native support; Copilot adopting). Locking canonical content in a tool-named file (CLAUDE.md) makes onboarding future harnesses harder. Claude Code happily follows a "see AGENTS.md" pointer with no degradation. Implemented in Phase B of the slim-overlay rework.

2026-04-26: Replace the audit-backlog → phase-execution → process-backlog skill chain with a single `/plan-backlog-item` skill. Opus authors a self-contained backlog entry — scope, file paths, acceptance criteria, verification steps, prose tier hint — appended to `roadmap.md` Backlog. Any cheaper agent (Sonnet, Haiku, GPT, Kimi) can execute without back-context. No claim arbitration; no `[~]` markers; whoever picks it up next, picks it up.

2026-04-28: Represent OpenAI Bundled Codex plugins as config-only enablement in chezmoi. The managed config enables `browser-use`, `computer-use`, and `latex-tectonic` plus a local `openai-bundled` marketplace pointer, while leaving plugin cache contents, proprietary assets, and bundled binaries under Codex-managed `~/.codex` runtime state instead of vendoring them into git. Codex MCP IDs may use a `serverId` override, currently `atlassian_rovo`, when a shared catalog ID must stay registry-compatible for Copilot/OpenCode.

2026-04-29: Add a global artifact-first spec-agent pack for Claude Code, GitHub Copilot CLI, and OpenCode. The stable agent names are `spec-planner`, `spec-implementer`, and `spec-verifier`; their model fields intentionally inherit each tool's active/default model so users can choose a planning tier, implementation tier, or mechanical verification tier at invocation time instead of maintaining provider-specific model IDs in every agent profile. V1 ships Claude/OpenCode command surfaces and Copilot `--agent` documentation; hooks stay as deferred follow-up work.

2026-04-29: Remove the Claude Code auto-commit Stop hook. The default remains "make a small local commit after code changes" in shared agent instructions and spec-implementer behavior, but broad Stop hooks are too noisy for normal dirty-worktree iteration. Future hooks should be narrow, opt-in, or deterministic guardrails rather than session-stop workflow enforcement.

2026-04-29: Install the OpenCode CLI through the fully qualified Homebrew formula `anomalyco/tap/opencode` in the personal bootstrap script. The old `sst/tap` source is no longer needed for the CLI, and `opencode-desktop` resolves from Homebrew cask directly.

2026-04-29: Add the local Logseq DB MCP as a work-only Codex/OpenCode catalog entry named `logseq-db`. The server token stays out of git in the macOS Keychain service `logseq-db-mcp-token`, exported as `LOGSEQ_DB_MCP_TOKEN`; Codex references it through `bearer_token_env_var`, while OpenCode uses its documented `{env:...}` config substitution in an `Authorization` header.

2026-04-29: Drop the spec-agent pack (`spec-planner`, `spec-implementer`, `spec-verifier`) added earlier the same day. Real-world use showed the synchronous tier-delegation workflow doesn't earn its overhead — implementer crashes get patched at parent-tier cost, killing the discount, and the only durable value (the spec artifact) is narrow to genuinely multi-phase work. The original "Opus drafts, cheaper models execute later" goal is already covered by `/plan-backlog-item`, which writes self-contained roadmap entries. Going forward, use built-in plan mode for same-session work and `/plan-backlog-item` for deferred work; write phase specs by hand in `.docs/ai/phases/` only when the work is genuinely multi-phase. Reverses the spec-agent-pack decision from earlier 2026-04-29.
