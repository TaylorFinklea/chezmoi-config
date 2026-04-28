# Roadmap

Durable goals and milestones for this repo. Update when scope changes, not every session.

## Vision

Keep personal dotfiles and AI-agent configuration aligned across Claude Code, Codex, Opencode, and GitHub Copilot CLI through one tracked chezmoi source of truth — with a deliberately thin overlay on each tool's vanilla harness.

## Now / Next / Later

Active items pulled from the previous next-steps log. Trim as completed.

### Now
- Restart Copilot CLI and verify the 7 "blocked by policy" MCP servers connect; if `io.github.hashicorp/terraform-mcp-server` is still blocked, request its addition to the TN MCP registry.
- Verify with the org admin that the TN registry URL (`https://tn-mcp-registry.azurewebsites.net`) is configured in GitHub org settings under Copilot → MCP Registry, with "Restrict MCP access to registry servers" enforced.
- Run `chezmoi apply` on this machine and bootstrap TPM so the managed tmux config and which-key menu are active under `~/.tmux.conf` and `~/.config/tmux/plugins/tmux-which-key/config.yaml`.
- Reload or restart tmux after `chezmoi apply` so the new Fish default shell takes effect for fresh sessions/windows/splits/TmuxAI popups.
- Apply the new managed `~/.config/tmuxai/config.yaml`, then verify `tmuxai --model codex` and `tmuxai --model copilot` both launch in tmux popups with expected credentials.

### Next
- Run `scripts/install-homebrew-work.sh` on a work machine and confirm `spacectl` installs cleanly from the `spacelift-io/spacelift` tap.
- Source `~/.zshrc` (or open a fresh Fish/Zsh) so the new `c` / `ccc` aliases land in already-open shells.
- Log in to `flyctl` and `railway` on this personal machine, then verify the managed `flyctl` and `railway` MCP entries connect from Codex and Opencode.
- Verify the repo-scoped Claude Code MCP entries (`supabase-personal`, `flyctl`, `railway`) connect cleanly in this repo. If you want personal/work scoping there too, introduce a managed home-level Claude MCP surface instead of relying only on `.mcp.json`.
- Validate `Cmd-h` / `Cmd-l` (tmux window navigation) and `Cmd-Shift-h` / `Cmd-Shift-l` (tmux window reorder) after restarting Ghostty, while AeroSpace keeps desktop-level focus behavior elsewhere.
- Decide whether `vim-tmux-navigator`'s `Ctrl-h/j/k/l` collides with any terminal AI TUI; if so, remap it while keeping the prefix-based pane navigation in `dot_tmux.conf`.
- Install Karabiner-Elements on this machine, then confirm the managed `Caps Lock`, `Ctrl-Space`, and `Ctrl-;` layers behave as intended in tmux, shells, Neovim, Claude Code, and Codex.

### Later
- Decide whether to keep powerline glyphs in the tmux status bar or swap them for plain separators on machines without a Nerd Font.
- If you want Espanso on personal machines too, add a personal-only managed match file (or profile-specific snippet path) instead of sharing the work `base.yml`.
- Roll the same `data.ai_profile` plus `chezmoi apply` verification through a personal machine and confirm scoped Codex/Copilot/Opencode renders match.
- Verify on a work machine that `~/.codex/skills/tn-*` and `~/.copilot/skills/tn-*` land cleanly and that the old non-`tn-` managed work-skill paths are removed.
- Decide whether any `build-web-apps` plugin skills need to remain available on work machines; today the whole plugin is personal-only because its bundled MCPs are personal-only.
- Keep the Claude Code Vercel plugin disabled unless actively working on Vercel-specific tasks; re-enable with `claude plugin enable vercel-plugin@vercel-vercel-plugin` when needed.

## Milestones

### M1: Cross-agent AI workflow parity (complete, archived)
- [x] Add repo-local AI handoff docs under `.docs/ai/`
- [x] Make Opus/T3 architect ownership vendor-neutral *(superseded — see M3)*
- [x] Add a managed GitHub Copilot CLI instruction surface alongside Claude and Codex
- [x] Normalize the shared workflow command set *(superseded — see M3)*
- [x] Add canonical workflow docs under `docs/` *(superseded — see M3)*
- [x] Add a reviewed import workflow for home-directory AI changes *(superseded — see M3)*

### M3: Slim the agent overlay
- [x] Delete unused workflow skills (audit-backlog, process-backlog, process-backlog-opus, resume-and-continue, import-ai-config-changes, phase-execution) across `dot_claude/`, `dot_copilot/`, `dot_agents/`
- [x] Delete `docs/ai-workflows/`, `docs/ai-roadmap-system.md`, `docs/ai-config-import-policy.md`, and the three import scripts in `scripts/`
- [x] Drop `tier3_owner` markers and the `[~]` claim protocol from this roadmap
- [x] Flip canonical instruction file to `AGENTS.md`; reduce `CLAUDE.md`, `dot_codex/AGENTS.md`, and `dot_copilot/copilot-instructions.md` to thin pointers + tool-specific overrides
- [x] Add `/plan-backlog-item` skill — Opus drafts self-contained backlog entries for cheaper agents to execute, no claim ceremony
- [ ] Migrate active downstream repos (finclaide, simmersmith, larkline, musicapp, joji) to the new instruction-file shape opportunistically

## Backlog

Self-contained items below. Each entry should include scope, file paths, acceptance criteria, verification steps, and a prose note about which model tier is appropriate ("Haiku candidate", "Sonnet — multi-file", "needs Opus to scope"). Any agent can pick up any item.

<!-- Format example:
### Add foo to bar
**Scope**: …
**Files**: `path/to/file.ts:42`
**Acceptance**: …
**Verify**: `npm test -- foo`
**Tier hint**: Sonnet — touches 2 files, no design decisions
-->

## Constraints

- Each tool's instructions surface (`CLAUDE.md`, `AGENTS.md`, `copilot-instructions.md`) must read sensibly when its tool ingests it. Future-proof toward `AGENTS.md` as the canonical file.
- Don't reintroduce protocol overhead for workflows the user doesn't actually run (parallel-tier dispatch, claim arbitration, cross-tool config sync). One agent at a time, switch tools per session.
