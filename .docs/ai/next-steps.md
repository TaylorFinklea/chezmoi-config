# Next Steps

Exact next actions for the incoming assistant. Keep this short, ordered, and actionable.

---

- [ ] Run `chezmoi apply` on this machine and bootstrap TPM so the new managed tmux config and which-key menu are active under `~/.tmux.conf` and `~/.config/tmux/plugins/tmux-which-key/config.yaml`.
- [ ] Apply the new managed `~/.config/tmuxai/config.yaml`, then verify `tmuxai --model codex` and `tmuxai --model copilot` both launch inside tmux popups with the expected credentials on this machine.
- [ ] Decide whether to keep the powerline glyphs in the tmux status bar as-is or swap them for plain separators on machines without a Nerd Font / Powerline-capable font.
- [ ] Validate the direct tmux `Alt-h` / `Alt-l` previous/next window bindings in the terminal apps you use most; if `Option`/`Meta` is inconsistent anywhere, decide whether to switch that machine to terminal-native mappings or Karabiner.
- [ ] If cross-app `vim-tmux-navigator` `Ctrl-h/j/k/l` behavior collides with any terminal AI TUI, decide whether to keep it enabled or remap it while preserving the prefix-based pane navigation in `dot_tmux.conf`.
- [ ] Install Karabiner-Elements on this machine, then confirm the new managed `Caps Lock`, `Ctrl-Space`, and `Ctrl-;` layers behave as intended in tmux, shells, Neovim, Claude Code, and Codex.
- [ ] Roll the same `data.ai_profile` plus `chezmoi apply` verification through a personal machine and confirm the scoped Codex, Copilot, and OpenCode renders match expectations there.
- [ ] Verify on a work machine that `~/.codex/skills/tn-*` and `~/.copilot/skills/tn-*` both land cleanly and that the old non-`tn-` managed TherapyNotes/PM skill paths are removed.
- [ ] Decide whether any `build-web-apps` plugin skills need to remain available on work machines; today the whole plugin is personal-only because its bundled plugin MCPs are personal-only.
- [ ] Decide which of the deferred local skill directories from the old importer should be discarded locally versus staged into `.docs/ai/inbox/`.
- [ ] Exercise `scripts/promote-ai-config-inbox.sh` on one real local addition and confirm the inbox metadata (`scope`, `targets`, `kind`) is sufficient before promoting more artifacts.
- [ ] If the work-only Codex skills should sync to other work machines, add the selected skill directories to git so the scoped ignore rules project them consistently.
- [ ] Verify in a real repo that Claude, Codex, Copilot, and OpenCode all interpret the normalized command set and shared instruction surfaces as intended.
