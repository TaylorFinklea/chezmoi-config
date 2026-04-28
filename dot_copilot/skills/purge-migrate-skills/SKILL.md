---
name: purge-migrate-skills
description: Remove all `migrate-*` skills from chezmoi-config and home directories across installed harnesses (Claude Code, Codex, Copilot, Agents). Use after a one-shot migration sweep is complete and the migration tooling is no longer needed. Self-removing — this skill deletes itself too.
user-invocable: true
disable-model-invocation: true
---

# Purge Migrate-* Skills

One-shot cleanup. Removes all `migrate-*` skills from your `~/git/chezmoi-config` repo (the source of truth) and applies the change so they disappear from `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, and `~/.agents/skills/`.

**This skill removes itself too** — it's part of the `migrate-*` family. The deletion happens through a chezmoi commit, so the skill files vanish from home only after `chezmoi apply` runs.

## Steps

### 1. Find chezmoi-config root

Default: `~/git/chezmoi-config`. Verify with:

```bash
test -d ~/git/chezmoi-config && echo OK
```

If the default path doesn't exist, ask the user for the actual chezmoi source directory.

### 2. List all `migrate-*` skill directories

```bash
find ~/git/chezmoi-config \
  -type d \
  -name 'migrate-*' \
  -path '*/skills/migrate-*'
```

Expect entries like:
- `~/git/chezmoi-config/dot_claude/skills/migrate-slim-overlay/`
- `~/git/chezmoi-config/dot_codex/skills/migrate-slim-overlay/`
- `~/git/chezmoi-config/dot_copilot/skills/migrate-slim-overlay/`
- `~/git/chezmoi-config/dot_claude/skills/purge-migrate-skills/` (this skill)
- `~/git/chezmoi-config/dot_codex/skills/purge-migrate-skills/`
- `~/git/chezmoi-config/dot_copilot/skills/purge-migrate-skills/`

Show the full list to the user.

### 3. Confirm

Use `AskUserQuestion` (or the equivalent for the active harness) with options:

1. **Yes — delete and run `chezmoi apply`** (Recommended) — removes from chezmoi tree, commits, propagates to home
2. **Yes — delete in chezmoi-config, skip `chezmoi apply`** — for if you want to review the commit first
3. **Cancel** — leave everything in place

### 4. Delete in chezmoi-config

```bash
git -C ~/git/chezmoi-config rm -r \
  dot_claude/skills/migrate-* \
  dot_codex/skills/migrate-* \
  dot_copilot/skills/migrate-* \
  dot_agents/skills/migrate-* \
  2>/dev/null || true
```

Use `2>/dev/null || true` so missing tool directories (e.g., dot_agents may not have any migrate-* skills) don't break the run.

After `git rm`, also clean up any empty parent directories — `git rm` doesn't delete empty dirs but a follow-up `git status` should show none if you only removed leaves.

### 5. Commit

```bash
git -C ~/git/chezmoi-config commit -m "chore: remove migrate-* skills (slim-overlay rollout complete)"
```

### 6. Apply

If the user picked option 1 in step 3:

```bash
chezmoi apply
```

This removes the skill directories from `~/.claude/skills/`, `~/.codex/skills/`, `~/.copilot/skills/`, and `~/.agents/skills/`.

**Note**: this skill itself is among the deleted files. The `chezmoi apply` invocation may run after the skill content is already removed from the live home tree (depending on harness), but the operation is sequenced through the OS, so it completes correctly.

### 7. Report

List what was deleted and confirm chezmoi apply succeeded:

```bash
git -C ~/git/chezmoi-config log -1 --stat
chezmoi diff | head -5  # should be empty if apply succeeded
ls ~/.claude/skills/ ~/.codex/skills/ ~/.copilot/skills/ 2>/dev/null | grep -c migrate || echo "0 migrate-* skills remaining"
```

## Failure modes

- **No `migrate-*` skills found**: print "Already purged" and exit cleanly. Idempotent — safe to invoke even after a previous purge.
- **chezmoi-config has uncommitted changes**: warn before `git rm` so the user can stash first; the new commit must not pick up unrelated drift.
- **`chezmoi apply` blocked by drift in unrelated managed files**: report the chezmoi error and let the user reconcile manually with `chezmoi diff` / targeted `chezmoi apply <path>`.

## Why this is a sibling skill

The `migrate-slim-overlay` skill couldn't reliably delete itself from inside its own execution context across all harnesses. A separate skill that any harness (Claude Code, Codex, Copilot) can invoke is more reliable. After this skill runs, both itself and `migrate-slim-overlay` are gone from chezmoi-config and from home directories.
