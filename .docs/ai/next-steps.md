# Next Steps

Exact next actions for the incoming assistant. Keep this short, ordered, and actionable.

---

- [ ] Roll the same `data.ai_profile` plus `chezmoi apply` verification through a personal machine and confirm the scoped Codex, Copilot, and OpenCode renders match expectations there.
- [ ] Decide whether any `build-web-apps` plugin skills need to remain available on work machines; today the whole plugin is personal-only because its bundled plugin MCPs are personal-only.
- [ ] Decide which of the deferred local skill directories from the old importer should be discarded locally versus staged into `.docs/ai/inbox/`.
- [ ] Exercise `scripts/promote-ai-config-inbox.sh` on one real local addition and confirm the inbox metadata (`scope`, `targets`, `kind`) is sufficient before promoting more artifacts.
- [ ] If the work-only Codex skills should sync to other work machines, add the selected skill directories to git so the scoped ignore rules project them consistently.
- [ ] Verify in a real repo that Claude, Codex, Copilot, and OpenCode all interpret the normalized command set and shared instruction surfaces as intended.
