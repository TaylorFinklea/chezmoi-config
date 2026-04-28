# Current State

Living snapshot of the project. Update before ending each AI session.

---

## Active Branch

`main`

## Recent Progress

- Imported local `~/.codex/config.toml` drift into the managed Codex source: enabled all three OpenAI Bundled plugins (`browser-use`, `computer-use`, `latex-tectonic`) through config-only marketplace/plugin entries, added Codex `chrome-devtools.new_page` approval, and rendered work-profile Atlassian as `atlassian_rovo` while preserving the registry-style ID for Copilot/OpenCode. Applied only `~/.codex/config.toml` with `chezmoi apply --force`; full `chezmoi apply` remains a separate Now item.
- Added the official Bun Homebrew tap (`oven-sh/bun`) and `bun` formula to `scripts/install-homebrew-personal.sh` so personal machine bootstrap installs Bun through the managed Homebrew script.
- Slimmed the AI-agent overlay (M3 milestone — three phases, all complete except per-repo migration). Phase A: deleted six workflow skills (audit-backlog, process-backlog, process-backlog-opus, resume-and-continue, import-ai-config-changes, phase-execution) across `dot_claude/`, `dot_copilot/`, `dot_codex/`, `dot_agents/`. Deleted `docs/ai-workflows/`, `docs/ai-roadmap-system.md`, `docs/ai-config-import-policy.md`, `dot_agents/templates/`, `.docs/ai/inbox/`, the three import scripts plus `_shared-exclusions.sh`, the `audit-backlog` Claude agent, and `.docs/ai/next-steps.md`. Stripped `tier3_owner` markers and the `[~]` claim protocol; folded the previous next-steps items into a Now/Next/Later section in `roadmap.md`. Phase B: flipped canonical instruction file to `AGENTS.md` (137 lines, comprehensive); reduced `CLAUDE.md` (23 lines), `dot_codex/AGENTS.md` (12 lines), and `dot_copilot/copilot-instructions.md` (19 lines) to thin pointers + tool-specific overrides. Phase C: added `/plan-backlog-item` Claude Code skill that produces self-contained backlog entries Opus can author for cheaper agents to execute later. Remaining: opportunistic per-repo `CLAUDE.md` → `AGENTS.md` migration when each downstream repo (finclaide, simmersmith, larkline, musicapp, joji) is next touched. A full `chezmoi apply` still has not been run for the slim-overlay/tmux changes — preview shows expected drift in `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, and `~/.agents/skills/`.
- Disabled the user-scope Claude Code `vercel-plugin@vercel-vercel-plugin` with `claude plugin disable`, leaving the installed plugin and cache intact so it can be re-enabled later without reinstalling.
- Added Ghostty `Cmd-Shift-h` / `Cmd-Shift-l` bindings that emit `Meta-H` / `Meta-L` so the existing tmux `swap-window` bindings can move the current window left and right.
- Updated the managed tmux config so tmux itself now defaults to `/opt/homebrew/bin/fish -l` for new sessions, windows, and splits, instead of inheriting zsh from the login shell.
- Switched the tmux `tmuxai` popup launchers from `/bin/zsh -lic` to `/opt/homebrew/bin/fish -ilc` so popup shells match the rest of the tmux environment.
- Added the official Spacelift Homebrew tap (`spacelift-io/spacelift`) and `spacectl` formula to `scripts/install-homebrew-work.sh` so work machines can install the Spacelift CLI through the managed brew sync script.
- Resolved the `.docs/ai/decisions.md` merge conflict by keeping both the personal MCP catalog decision and the profile-scoped Espanso decisions, so the branch can be finalized without dropping either line of history.
- Added personal-scope MCP fanout entries in `.chezmoidata/ai.json` for `supabase-personal`, `flyctl`, and `railway`, rendering them into the managed personal Codex and OpenCode configs.
- Updated the repo-scoped `.mcp.json` used for Claude Code in this repo to expose `supabase-personal`, `flyctl`, and `railway` alongside `chrome-devtools`.
- Added `flyctl` and `railway` to `scripts/install-homebrew-personal.sh`, then installed both CLIs locally; `supabase`, `flyctl`, and `railway` are now all present under `/opt/homebrew/bin`.
- Applied the managed personal Codex and OpenCode config files directly with `chezmoi apply ~/.codex/config.toml ~/.config/opencode/opencode.json` after a full `chezmoi apply` stopped on unrelated local drift in `~/.config/fish/config.fish`.
- Moved the LM Studio Fish PATH addition into the managed `dot_config/fish/config.fish` file as `fish_add_path ~/.lmstudio/bin`, then force-applied just `~/.config/fish/config.fish` so the repo now owns that change too.
- Updated the managed Claude shell aliases in both `dot_zshrc` and `dot_config/fish/config.fish` so `c` runs `claude --permission-mode bypassPermissions` and `ccc` runs `claude -c --permission-mode bypassPermissions`, while leaving `ccr` unchanged.
- Restored the LM Studio zsh PATH entry as managed repo content in `dot_zshrc` after a targeted force-apply exposed that `~/.zshrc` had the same old unmanaged local edit as Fish.
- Added a new chezmoi-managed tmux setup at `dot_tmux.conf` with a lean, window-centric workflow tuned for Claude Code, Codex, Neovim, and other terminal TUIs.
- Added direct tmux window cycling on `Alt-h` / `Alt-l`, then remapped the primary desktop shortcut path to Ghostty `Cmd-h` / `Cmd-l` sending `Meta-h` / `Meta-l` so AeroSpace can own directional movement without changing the tmux bindings themselves.
- Added a small XDG `tmux-which-key` menu config at `dot_config/tmux/plugins/tmux-which-key/config.yaml` so prefix-driven discovery matches the direct bindings in the managed tmux config.
- Added managed TmuxAI config at `dot_config/tmuxai/config.yaml.tmpl` with `codex` and `copilot` model profiles, plus tmux popup launchers and which-key entries for both.
- Updated the managed TmuxAI model selections to use `gpt-5.4` for the Codex/OpenAI profile and `claude-sonnet-4.6` for the Copilot profile.
- Removed the explicit Copilot auth token from the managed TmuxAI config so the `github-copilot` provider relies on the logged-in `copilot` CLI state, matching the upstream tmuxai docs.
- Added a work-only chezmoi-managed Espanso base match file at `private_Library/private_Application Support/espanso/match/base.yml` and applied it on this machine so `kub` expands to `Kubernetes` without affecting personal machines.
- Added a separate personal-only Espanso match file at `private_Library/private_Application Support/espanso/match/personal-email.yml` so personal machines can map `,,em` to `taylor.finklea@gmail.com` without sharing the work snippet set.
- Switched the tmux prefix to `C-a`, moved the status bar to the top, enabled mouse + vi copy mode, made splits inherit the current pane path, and added direct bindings for popup shells, choose-tree navigation, zoom, reload, and session save/restore.
- Kept tmux-resurrect pane-content capture disabled by default so persistence is practical without storing large or sensitive AI scrollback.
- Disabled tmux automatic window renaming so manual names set with `C-a ,` persist in the status bar instead of being replaced by the active command name.
- Added a new chezmoi-managed Karabiner profile at `dot_config/karabiner/karabiner.json` with dual-role `Caps Lock` and two small Control-based layers for navigation and numpad-style entry.
- Replaced hostname-based AI config selection with explicit `data.ai_profile` handling for chezmoi-managed AI configuration.
- Added `.chezmoidata/ai.json` as the shared AI catalog for scoped MCP servers, OpenCode instruction inputs, discovery roots, and work-only Codex artifact paths.
- Refactored Codex and Copilot MCP rendering so work/personal differences come from the shared catalog instead of duplicated hand-edited blocks.
- Added managed OpenCode global config at `dot_config/opencode/opencode.json.tmpl`, including shared `~/AGENTS.md` instructions and scoped MCP server rendering.
- Converted `.chezmoiignore` into `.chezmoiignore.tmpl` so work-only Codex skills are ignored automatically on personal machines.
- Added `deferredSourcePaths` handling in `.chezmoidata/ai.json` and `.chezmoiignore.tmpl` so old importer-created source directories no longer participate in `chezmoi apply` until explicitly promoted.
- Added matching root `.gitignore` entries for those deferred source directories so the repo stops reporting a wall of untracked importer leftovers during normal work.
- Moved Codex plugin enablement into the shared AI catalog and made `build-web-apps@openai-curated` personal-only because that plugin bundles `stripe`, `vercel`, and `supabase` MCP servers through its own plugin-local `.mcp.json`.
- Renamed the TherapyNotes and PM work skills to a consistent `tn-*` prefix and copied that work-only set into `dot_copilot/skills/` so the same TherapyNotes workflows can land on work Copilot machines.
- Replaced tool-specific absolute skill cross-links with relative references so the `tn-*` workflows work from both Codex and Copilot skill trees.
- Replaced `scripts/sync-ai-configs.sh` with a review-only wrapper and added `scripts/promote-ai-config-inbox.sh` plus `.docs/ai/inbox/` for explicit staging/classification of newly discovered local AI artifacts.
- Bootstrapped `./.docs/ai/` from `~/.codex/templates/docs-ai/` for repo-local AI handoff state.
- Synced the tracked chezmoi source for `~/.codex/AGENTS.md` with the current home-directory file contents.
- Added repo documentation for the GitHub PAT bootstrap flow in `README.md`, `CLAUDE.md`, and `AGENTS.md`, including the Keychain service name `codex-github-pat`, the exported variable `GITHUB_PAT_TOKEN`, and the `launchd` loader command.
- Made the AI roadmap contract vendor-neutral so `tier3_owner` can be `claude`, `codex`, `copilot`, or `unassigned`.
- Added canonical shared documentation in `docs/ai-roadmap-system.md` and `docs/ai-workflows/` so this repo is the source of truth for the cross-tool roadmap workflow.
- Normalized the shared workflow command set across Claude, Codex, Copilot, and generic agents:
  - `/audit-backlog`
  - `/process-backlog` for Haiku/Sonnet
  - `/process-backlog-opus` for Opus/T3
  - `/resume-and-continue`
- Added full skill parity across `dot_claude/skills/`, `dot_codex/skills/`, `dot_copilot/skills/`, and `dot_agents/skills/` using thin wrappers that point to the canonical workflow docs.
- Updated `scripts/sync-ai-configs.sh` so Copilot skills are synced and the four repo-managed workflow skills are excluded from home-directory skill imports instead of being deleted or overwritten during sync.
- Reworked `scripts/sync-ai-configs.sh` again after a real apply showed destructive behavior: it is now a conservative importer for optional home-created skills, agents, and templates, and it no longer imports repo-managed root docs or machine-specific `~/.codex/config.toml`.
- Added `docs/ai-config-import-policy.md`, a canonical `import-ai-config-changes` workflow doc, and matching Claude/Codex skills so future home-directory imports are reviewed for safety before sync.
- Added `scripts/review-ai-config-imports.sh` to classify home-directory changes as safe additions, review-required tracked diffs, blocked repo-managed conflicts, or ignored machine-local paths.
- Tightened `scripts/sync-ai-configs.sh` again so it imports only brand-new top-level additions from home skill, agent, and template trees, and skips existing tracked paths entirely.
- Added Chrome DevTools MCP as a repo-managed browser-debugging server:
  - Codex via the managed `~/.codex/config.toml` template
  - Copilot CLI via managed `~/.copilot/mcp-config.json`
  - Claude Code via the repo-scoped `.mcp.json`
- Set `data.ai_profile = "work"` in the live `~/.config/chezmoi/chezmoi.toml` on this machine and applied the scoped Codex, Copilot, and OpenCode outputs successfully.
- Imported local VS Code `settings.json` changes into the chezmoi repo (local was a superset of the repo version).
- Fixed the TN MCP registry (`tn-mcp-registry.azurewebsites.net`) returning 403 on `/v0/servers` — IIS rewrite was targeting a physical directory path instead of the JSON file. PR #14 merged in `therapynotes-it/infrastructure.mcpregistry`.
- Renamed all 8 work-scoped Copilot MCP server IDs from friendly names (e.g. `atlassian`, `figma-work`) to their canonical TN registry reverse-DNS names (e.g. `com.atlassian/atlassian-mcp-server`, `com.figma.mcp/mcp`) so they match the org allowlist enforcement.
- Removed the `atlassian_rovo` → `atlassian` special-case logic from both the Copilot and OpenCode templates.

## Changed Files

- `scripts/install-homebrew-personal.sh`
- `dot_tmux.conf`
- `.chezmoidata/ai.json`
- `dot_config/fish/config.fish`
- `dot_zshrc`
- `.mcp.json`
- `README.md`
- `scripts/install-homebrew-work.sh`
- `scripts/install-homebrew-personal.sh`
- `dot_config/tmux/plugins/tmux-which-key/config.yaml`
- `dot_config/tmuxai/config.yaml.tmpl`
- `dot_config/tmuxai/README.md`
- `dot_config/tmux/cheatsheet.txt`
- `private_Library/private_Application Support/com.mitchellh.ghostty/config`
- `private_Library/private_Application Support/espanso/match/base.yml`
- `private_Library/private_Application Support/espanso/match/personal-email.yml`
- `dot_config/karabiner/karabiner.json`
- `.docs/ai/current-state.md`
- `.docs/ai/decisions.md`
- `.docs/ai/next-steps.md`
- `.docs/ai/roadmap.md`
- `.gitignore`
- `.mcp.json`
- `docs/ai-config-import-policy.md`
- `docs/ai-roadmap-system.md`
- `docs/ai-workflows/audit-backlog.md`
- `docs/ai-workflows/import-ai-config-changes.md`
- `docs/ai-workflows/process-backlog.md`
- `docs/ai-workflows/process-backlog-opus.md`
- `docs/ai-workflows/resume-and-continue.md`
- `dot_agents/skills/audit-backlog/SKILL.md`
- `dot_agents/skills/process-backlog/SKILL.md`
- `dot_agents/skills/process-backlog-opus/SKILL.md`
- `dot_agents/skills/resume-and-continue/SKILL.md`
- `dot_claude/skills/audit-backlog/SKILL.md`
- `dot_claude/skills/process-backlog/SKILL.md`
- `dot_claude/skills/process-backlog-opus/SKILL.md`
- `dot_claude/skills/resume-and-continue/SKILL.md`
- `dot_claude/skills/import-ai-config-changes/SKILL.md`
- `dot_codex/AGENTS.md`
- `.chezmoitemplates/codex/personal.toml`
- `.chezmoitemplates/codex/work.toml`
- `dot_codex/skills/audit-backlog/SKILL.md`
- `dot_codex/skills/import-ai-config-changes/SKILL.md`
- `dot_codex/skills/process-backlog/SKILL.md`
- `dot_codex/skills/process-backlog-opus/SKILL.md`
- `dot_codex/skills/resume-and-continue/SKILL.md`
- `private_Library/private_Application Support/private_Code/User/settings.json`
- `dot_copilot/mcp-config.json.tmpl`
- `dot_config/opencode/opencode.json.tmpl`
- `dot_copilot/copilot-instructions.md`
- `dot_copilot/skills/audit-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog/SKILL.md`
- `dot_copilot/skills/process-backlog-opus/SKILL.md`
- `dot_copilot/skills/resume-and-continue/SKILL.md`
- `AGENTS.md`
- `CLAUDE.md`
- `README.md`
- `.chezmoidata/ai.json`
- `.chezmoiignore.tmpl`
- `.docs/ai/inbox/README.md`
- `scripts/review-ai-config-imports.sh`
- `scripts/sync-ai-configs.sh`
- `scripts/promote-ai-config-inbox.sh`
- `dot_config/chezmoi/chezmoi.toml.tmpl`
- `dot_config/opencode/opencode.json.tmpl`
- `dot_config/opencode/README.md`

## Blockers

- The old importer-created source directories still exist on disk; they are now ignored by both chezmoi and git until you decide which ones should be promoted into the scoped catalog versus deleted locally.

## Open Questions

- (none)

## Validation / Test Status

```
Ran `bash -n scripts/install-homebrew-personal.sh` successfully after adding the Bun tap and formula to the personal Homebrew script.
Verified all four workflow skill names exist under Claude, Codex, Copilot, and generic agent skill trees.
Validated `dot_tmux.conf` syntax with `tmux -L codex-tmux-check -f /Users/tfinklea/git/chezmoi-config/dot_tmux.conf start-server` after setting Fish as the tmux default shell/command and updating the TmuxAI popup launchers.
Fetched the upstream `tmuxai` `config.example.yaml` and confirmed the supported provider set includes `openai` and `github-copilot`, with `github-copilot` requiring the `copilot` CLI in `PATH`.
Verified from GitHub Docs on 2026-04-10 that GitHub Copilot currently lists both `Claude Sonnet 4.6` and `GPT-5.4` as supported models.
Validated `dot_tmux.conf` syntax with `tmux 3.6a` using `tmux -L codex-tmux-check -f ... start-server`.
Revalidated `dot_tmux.conf` syntax with `tmux 3.6a` after adding direct `Alt-h` / `Alt-l` previous/next window bindings.
Updated the managed Ghostty config so `Cmd-h` / `Cmd-l` send `Meta-h` / `Meta-l` into tmux, leaving the tmux-side window bindings unchanged while freeing `Alt-h` / `Alt-l` for AeroSpace.
Updated and applied the managed Ghostty config so `Cmd-Shift-h` / `Cmd-Shift-l` send `Meta-H` / `Meta-L` into tmux for window reordering; `git diff --check` passed.
Parsed `dot_config/tmux/plugins/tmux-which-key/config.yaml` successfully with Ruby YAML.
Validated `dot_config/karabiner/karabiner.json` with `jq empty` and applied it to `~/.config/karabiner/karabiner.json`.
Ran ./scripts/sync-ai-configs.sh --dry-run successfully after adding Copilot skill sync and excluding the repo-managed workflow skills from imported home skill directories.
Restored the repo after an unsafe full sync attempt, then reran ./scripts/sync-ai-configs.sh --dry-run successfully with the hardened additive-only import behavior.
Ran bash -n successfully for scripts/review-ai-config-imports.sh and scripts/sync-ai-configs.sh.
Ran ./scripts/review-ai-config-imports.sh successfully; the current report shows 55 safe additions, 3 review-required tracked path diffs, 3 blocked repo-managed instruction conflicts, and 3 ignored machine-local or managed paths.
Confirmed the importer dry run now skips repo-managed files and existing tracked paths, and only proposes additive top-level imports.
Validated `.mcp.json` and `dot_copilot/mcp-config.json.tmpl` with `jq empty`.
Rendered `dot_codex/private_config.toml.tmpl` through `chezmoi execute-template` and confirmed the `mcp_servers.chrome-devtools` entry appears in the active host config.
Ran `bash -n` successfully for `scripts/install.sh`, `scripts/sync-ai-configs.sh`, `scripts/review-ai-config-imports.sh`, and `scripts/promote-ai-config-inbox.sh`.
Rendered managed Codex config for `work` and `personal` profiles with `chezmoi cat`; confirmed `atlassian_rovo` appears only in `work` and `simmersmith` appears only in `personal`.
Rendered managed Copilot and OpenCode configs for both profiles and validated the JSON with `jq empty`.
Verified `.chezmoiignore.tmpl` causes the work-only Codex skill paths to appear in `chezmoi ignored` for the personal profile.
Ran `CHEZMOI_AI_PROFILE=work ./scripts/sync-ai-configs.sh --report ...` successfully; it now stays review-only and does not import directly into managed trees.
Verified `CHEZMOI_AI_PROFILE=work chezmoi -S . ignored` includes the deferred source paths and `chezmoi -S . managed` excludes them.
Ran a full `chezmoi apply -v` successfully after adding deferred source path ignores; the work machine now has the scoped Codex, Copilot, and OpenCode config rendered from this repo.
Confirmed the lingering work-machine `stripe`, `vercel`, and `supabase` MCPs were coming from the enabled `build-web-apps` Codex plugin rather than `~/.codex/config.toml`.
Verified the renamed `tn-*` skill set exists under both `dot_codex/skills/` and `dot_copilot/skills/`, with cross-links rewritten away from `~/.codex/skills/...` home paths.
Validated `.chezmoidata/ai.json` and `.mcp.json` with `jq empty`.
Ran `bash -n scripts/install-homebrew-personal.sh` successfully after adding `flyctl` and `railway`.
Installed `flyctl 0.4.33` and `railway 4.37.1` with Homebrew; `supabase 2.84.2` was already installed.
Verified `HOME=/tmp fly mcp server --claude --config /tmp/fly-mcp-config.json` writes a stdio MCP definition using `/opt/homebrew/bin/fly mcp server`, and used that exact shape in the managed configs.
Verified `railway --help` exposes a first-party `railway mcp` command in CLI v4.37.1, and used `/opt/homebrew/bin/railway mcp` in the managed configs.
Rendered the personal Codex and OpenCode configs with `chezmoi cat` and confirmed they contain `supabase-personal`, `flyctl`, and `railway`.
Applied `~/.codex/config.toml` and `~/.config/opencode/opencode.json` successfully with a targeted `chezmoi apply -v` run after a full apply stopped on `~/.config/fish/config.fish` drift.
Updated `dot_config/fish/config.fish` to manage `~/.lmstudio/bin` with `fish_add_path`, then ran `chezmoi apply --force -v ~/.config/fish/config.fish` successfully to remove the local unmanaged LM Studio PATH block.
Updated the managed `c` and `ccc` aliases in both Zsh and Fish, applied `~/.config/fish/config.fish` with `chezmoi apply --force -v`, and applied `~/.zshrc` with `chezmoi apply -v`.
Restored the LM Studio zsh PATH by adding `export PATH="$PATH:$HOME/.lmstudio/bin"` to `dot_zshrc`, then reapplied `~/.zshrc`.
Confirmed `claude plugins list` reports `vercel-plugin@vercel-vercel-plugin` as installed at user scope with status disabled after running `claude plugin disable vercel-plugin@vercel-vercel-plugin`.
Ran `bash -n scripts/install-homebrew-work.sh` successfully after adding the Spacelift Homebrew tap and `spacectl` formula.
Rendered Copilot MCP config with `chezmoi execute-template` and confirmed all 8 work-scoped servers use registry reverse-DNS names.
Applied `~/.copilot/mcp-config.json` with `chezmoi apply` and confirmed the deployed config contains the correct registry-matching server IDs.
Verified TN registry `/v0/servers` returns HTTP 200 with valid JSON listing 10 servers after the rewrite rule fix.
Rendered work and personal `~/.codex/config.toml` profiles with `chezmoi cat`, parsed both with Python `tomllib`, and confirmed OpenAI Bundled plugins, `marketplaces.openai-bundled`, `chrome-devtools.tools.new_page`, and work-only `atlassian_rovo` render correctly.
Ran `CHEZMOI_AI_PROFILE=work chezmoi -S . apply --dry-run --force ~/.codex/config.toml` successfully, then applied only `~/.codex/config.toml` with `chezmoi apply --force`.
Parsed the deployed `~/.codex/config.toml` with Python `tomllib` and confirmed it contains `browser-use@openai-bundled`, `computer-use@openai-bundled`, `latex-tectonic@openai-bundled`, the local `openai-bundled` marketplace pointer, `chrome-devtools.tools.new_page`, `atlassian_rovo`, and repo-default `bel` notifications.
Ran `jq empty .chezmoidata/ai.json` and `git diff --check` successfully.

```
