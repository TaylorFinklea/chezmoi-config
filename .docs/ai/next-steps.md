# Next Steps

Exact next actions for the incoming assistant. Keep this short, ordered, and actionable.

---

- [ ] Apply this repo and verify the managed workflow skills install to `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, and `~/.agents/skills/` as expected.
- [ ] Run `chezmoi diff` and `chezmoi apply` to land the new `~/.aerospace.toml`, `~/.config/sketchybar/`, and `~/Library/Fonts/sketchybar-app-font.ttf` files from this repo.
- [x] Decide whether `~/.codex/config.toml` should become a host-aware chezmoi template or remain intentionally unmanaged across work/personal machines.
- [ ] Run `chezmoi apply` on each machine so the managed Codex and Copilot MCP config changes land in `~/.codex/config.toml` and `~/.copilot/mcp-config.json`.
- [ ] Run `chezmoi apply ~/.claude/hooks/auto-commit-on-stop.sh` (or full `chezmoi apply`) on each machine so the managed Claude Stop hook uses the supported exit-code flow instead of invalid Stop-hook JSON.
- [ ] Decide whether to import any of the 55 currently safe additive home skill additions surfaced by `./scripts/review-ai-config-imports.sh`, or leave them untracked for now.
- [ ] Inspect the 3 review-required tracked path diffs before importing anything from those paths: `~/.codex/skills/playwright`, `~/.codex/skills/chatgpt-apps`, and `~/.agents/skills/find-skills`.
- [ ] Keep the 3 blocked repo-managed instruction files source-of-truth here in the repo unless you intentionally want to port specific changes back by hand: `~/AGENTS.md`, `~/CLAUDE.md`, and `~/.codex/AGENTS.md`.
- [ ] Verify in a real repo that Claude, Codex, and Copilot all interpret the normalized command set the same way, especially the `/process-backlog` vs `/process-backlog-opus` split.
- [ ] Update downstream project roadmaps from the old simple template to the tiered template and set `tier3_owner` explicitly per project.
- [ ] If the GitHub PAT bootstrap flow changes, update all three root docs together: `README.md`, `CLAUDE.md`, and `AGENTS.md`.
