# Next Steps

Exact next actions for the incoming assistant. Keep this short, ordered, and actionable.

---

- [ ] Set `data.ai_profile = "work"` or `"personal"` in `~/.config/chezmoi/chezmoi.toml` on each machine, then run `chezmoi apply`.
- [ ] Verify the new profile-aware managed files land cleanly on each machine: `~/.codex/config.toml`, `~/.copilot/mcp-config.json`, and `~/.config/opencode/opencode.json`.
- [ ] Decide which of the remaining untracked local skill directories from the old importer should be discarded locally versus staged into `.docs/ai/inbox/`.
- [ ] Exercise `scripts/promote-ai-config-inbox.sh` on one real local addition and confirm the inbox metadata (`scope`, `targets`, `kind`) is sufficient before promoting more artifacts.
- [ ] If the work-only Codex skills should sync to other work machines, add the selected skill directories to git so the scoped ignore rules project them consistently.
- [ ] Verify in a real repo that Claude, Codex, Copilot, and OpenCode all interpret the normalized command set and shared instruction surfaces as intended.
