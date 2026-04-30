# Current State

Last-session breadcrumb. Update before ending each AI session. Older history lives in `git log`.

---

## Active Branch

`main`

## Recent Progress

- Dropped the global spec-agent pack (`spec-planner`, `spec-implementer`, `spec-verifier`) and their slash commands across Claude Code, GitHub Copilot CLI, and OpenCode. Real-world dogfood showed the synchronous tier-delegation workflow didn't earn its overhead — implementer crashes get patched at parent-tier cost, and the only durable value (the spec artifact) is narrow to multi-phase work covered by hand-written `.docs/ai/phases/<slug>-spec.md` files plus `/plan-backlog-item`. Stripped every doc reference and removed the live destination files.
- Added the local Logseq DB MCP endpoint (`http://127.0.0.1:12315/mcp`) as a work-only `logseq-db` entry for Codex and OpenCode only. Auth token stored in macOS Keychain service `logseq-db-mcp-token`, exported as `LOGSEQ_DB_MCP_TOKEN` by zsh/fish and a LaunchAgent loader; never rendered literally into managed config.
- Removed the Claude Code auto-commit Stop hook from managed settings and deleted its script. Commits remain the default agent convention, but Claude no longer blocks session stopping.

## Blockers

- Local `opencode mcp list` still fails before config inspection with `Failed to run the query 'PRAGMA wal_checkpoint(PASSIVE)'`; OpenCode verification for `logseq-db` was done by rendering and parsing `~/.config/opencode/opencode.json` instead.
- Old importer-created source directories still exist on disk; ignored by chezmoi and git until you decide which to promote into the scoped catalog versus delete locally.

## Open Questions

- (none)
