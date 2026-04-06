# Next Steps

Exact next actions for the incoming assistant. Keep this short, ordered, and actionable.

---

- [ ] Apply this repo and verify the managed workflow skills install to `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, and `~/.agents/skills/` as expected.
- [ ] Decide whether `~/.codex/config.toml` should become a host-aware chezmoi template or remain intentionally unmanaged across work/personal machines.
- [ ] If you want to import the large new home skill additions shown by `./scripts/sync-ai-configs.sh --dry-run`, review and stage them intentionally instead of treating sync as a mirror operation.
- [ ] Verify in a real repo that Claude, Codex, and Copilot all interpret the normalized command set the same way, especially the `/process-backlog` vs `/process-backlog-opus` split.
- [ ] Update downstream project roadmaps from the old simple template to the tiered template and set `tier3_owner` explicitly per project.
- [ ] If the GitHub PAT bootstrap flow changes, update all three root docs together: `README.md`, `CLAUDE.md`, and `AGENTS.md`.
