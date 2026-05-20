---
description: Triage chezmoi drift without applying changes
---
Triage chezmoi drift. Run read-only inspection only: `chezmoi status`, `chezmoi diff`, and `git status` in the source repo. Do not run `chezmoi apply` unless I explicitly approve.

Classify each drifted path into exactly one bucket:

1. Source is right, home is stale (apply would fix it)
2. Home is right, source is stale (the source needs updating from home)
3. Both changed intentionally and need a manual merge
4. Unknown, needs my decision

For shell rc files, tmux, editor configs, and other actively hand-edited configs, assume home-side drift may be intentional. Report the classification as a table and recommend the safe next step per path, but take no action.
