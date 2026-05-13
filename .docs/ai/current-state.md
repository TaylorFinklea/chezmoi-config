# Current State

Last-session breadcrumb. Update before ending each AI session. Older history lives in `git log`.

---

## Active Branch

`main`

## Recent Progress

- Suppressed Ghostty's macOS clipboard-read prompts from terminal programs by setting `clipboard-read = deny` while leaving `clipboard-write = allow` at its default. Applied the managed Ghostty config locally; both the Library config and `~/.config/ghostty/config` symlink report the setting.
- Updated the Neovim LSP/LazyVim override so diagnostic virtual text is suppressed for `markdown` and `markdown.mdx` buffers while preserving the existing LazyVim diagnostic settings for other filetypes. Applied the managed file to `~/.config/nvim/lua/plugins/lsp.lua`; target `chezmoi diff` is clean.
- Fixed clipboard behavior for Neovim inside tmux: tmux now allows app clipboard writes with `set-clipboard on`, tmux copy-mode `y` pipes selections to `pbcopy`, and Neovim forces the built-in `tmux` clipboard provider when `$TMUX` is set. Applied both managed files locally; the stale/broken Nix `~/.config/nvim/lua/config/options.lua` symlink was replaced by the chezmoi-managed regular file.
- Added OpenCode to the shared `github` MCP catalog entry using the hosted GitHub MCP endpoint plus `GITHUB_PAT_TOKEN` as an Authorization header, with OAuth disabled for that PAT-backed path.
- Renamed the personal Supabase MCP catalog entry from `supabase-personal` to `supabase`, and made OpenCode's Supabase OAuth config explicit (`oauth: {}`) so the renamed server gets a clean OAuth identity instead of reusing stale cached client state.
- Fixed the OpenCode config template to JSON-encode object-valued `oauth` settings; rendered personal/work OpenCode templates now emit valid `oauth: false` and `oauth: {}` values.
- Applied the managed OpenCode config locally and verified `opencode mcp list`: `github`, `flyctl`, and `railway` connect; `supabase` is present under the new name and needs browser OAuth auth; the previous SQLite WAL checkpoint failure did not reproduce. `opencode mcp debug supabase` now reaches Supabase's expected OAuth challenge instead of the prior `Unrecognized client_id` response.
- Added a managed global OpenCode plugin at `~/.config/opencode/plugins/tmux-bell.js` that listens for OpenCode's `session.idle` event and emits BEL to `/dev/tty`, so tmux can use the existing `monitor-bell` / `window-status-bell-style` path when OpenCode finishes a task.
- Resolved local Codex chezmoi drift: promoted `/Users/tfinklea/git/schedule-studio` into the personal trusted-project template, kept the local `gpt-5.5` NUX counter at `4`, applied the Supabase MCP rename to `~/.codex/config.toml`, and force-applied the repo-managed daemon-based `~/.codex/hooks.json`. `chezmoi update` now completes without prompting.
- Bootstrapped tmux plugins through chezmoi externals in `.chezmoiexternal.toml` instead of vendoring plugin code. `chezmoi apply` now clones/updates TPM, tmux-sensible, tmux-which-key, vim-tmux-navigator, tmux-resurrect, and tmux-continuum under `~/.tmux/plugins` with weekly refreshes and fast-forward-only pulls.
- Removed the stale Home Manager `~/.config/tmux/tmux.conf` symlink via `.chezmoiremove`; this repo's canonical tmux config remains `~/.tmux.conf`.
- Applied the tmux-only chezmoi target set locally, reloaded tmux, and wrote a resurrect snapshot for the active 15-window `tesela` session. Current restore pointer: `~/.local/share/tmux/resurrect/last -> tmux_resurrect_20260509T194629.txt`.
- Added a managed Espanso global config at `~/Library/Application Support/espanso/config/default.yml` and disabled the default Option+Space search shortcut with `search_shortcut: OFF`. Applied it to the live home config; Espanso detected the change and restarted its worker.
- Dropped the global spec-agent pack (`spec-planner`, `spec-implementer`, `spec-verifier`) and their slash commands across Claude Code, GitHub Copilot CLI, and OpenCode. Real-world dogfood showed the synchronous tier-delegation workflow didn't earn its overhead — implementer crashes get patched at parent-tier cost, and the only durable value (the spec artifact) is narrow to multi-phase work covered by hand-written `.docs/ai/phases/<slug>-spec.md` files plus `/plan-backlog-item`. Stripped every doc reference and removed the live destination files.
- Added the local Logseq DB MCP endpoint (`http://127.0.0.1:12315/mcp`) as a work-only `logseq-db` entry for Codex and OpenCode only. Auth token stored in macOS Keychain service `logseq-db-mcp-token`, exported as `LOGSEQ_DB_MCP_TOKEN` by zsh/fish and a LaunchAgent loader; never rendered literally into managed config.
- Removed the Claude Code auto-commit Stop hook from managed settings and deleted its script. Commits remain the default agent convention, but Claude no longer blocks session stopping.

## Blockers

- Old importer-created source directories still exist on disk; ignored by chezmoi and git until you decide which to promote into the scoped catalog versus delete locally.

## Open Questions

- Confirm in a real OpenCode TUI session that the `session.idle` plugin bell fires at the right time without duplicate alerts from the project-local Moshi plugin.
