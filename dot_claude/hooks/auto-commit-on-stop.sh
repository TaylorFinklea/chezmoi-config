#!/usr/bin/env bash
# Auto-commit hook: fires on Stop, blocks once if uncommitted changes exist,
# and tells Claude to dispatch the commit agent using the supported
# exit-code-2 + stderr flow for Stop hooks.

set -euo pipefail

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null || true)"

guard_dir="${TMPDIR:-/tmp}"
guard_file="$guard_dir/.claude-auto-commit-${session_id:-fallback}"

# Second pass: guard exists -> clean up and let Claude stop.
if [[ -f "$guard_file" ]]; then
  rm -f "$guard_file"
  exit 0
fi

# Only act inside git repos.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Only act when there are uncommitted changes.
changes="$(git status --porcelain 2>/dev/null || true)"
[[ -n "$changes" ]] || exit 0

# Set guard so the next Stop pass exits cleanly.
touch "$guard_file"

cat >&2 <<'EOF'
AUTO-COMMIT: You have uncommitted changes in the working tree. Dispatch the commit agent (Agent tool with model: haiku) to create a clean local commit before stopping. Give it a brief description of what changed and which files to stage. Do NOT push - just commit locally.
EOF

exit 2
