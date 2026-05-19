#!/bin/bash
# Stop hook (asyncRewake: true): re-wake the model when this session
# changed source files without touching .docs/ai/current-state.md.
#
# Fires at most once per session — second time the model attempts to stop,
# the sentinel file blocks re-firing. Honors `stop_hook_active` for the
# canonical anti-loop guard too.

set -uo pipefail

JQ="${JQ:-jq}"
command -v "$JQ" >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | "$JQ" -r '.cwd // empty' 2>/dev/null || true)"
[ -z "$cwd" ] && cwd="${PWD:-}"
[ -n "$cwd" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0

[ -d ".docs/ai" ] || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
current_state=".docs/ai/current-state.md"
[ -f "$current_state" ] || exit 0

stop_active="$(printf '%s' "$input" | "$JQ" -r '.stop_hook_active // false' 2>/dev/null || echo false)"
[ "$stop_active" = "true" ] && exit 0

session_id="$(printf '%s' "$input" | "$JQ" -r '.session_id // empty' 2>/dev/null || true)"
state_dir="$HOME/.cache/claude-handoff"
mkdir -p "$state_dir" 2>/dev/null || true

fired_flag=""
if [ -n "$session_id" ]; then
  fired_flag="$state_dir/${session_id}.fired"
  [ -f "$fired_flag" ] && exit 0
fi

start_sha=""
if [ -n "$session_id" ] && [ -f "$state_dir/${session_id}.start" ]; then
  start_sha="$(cat "$state_dir/${session_id}.start" 2>/dev/null || true)"
fi
current_head="$(git rev-parse HEAD 2>/dev/null || true)"
[ -z "$current_head" ] && exit 0

session_source_commits=0
session_doc_commits=0
if [ -n "$start_sha" ] && [ "$start_sha" != "$current_head" ]; then
  session_source_commits="$(git log --oneline "${start_sha}..${current_head}" -- ':!.docs/ai/**' 2>/dev/null | wc -l | tr -d ' ')"
  session_doc_commits="$(git log --oneline "${start_sha}..${current_head}" -- "$current_state" 2>/dev/null | wc -l | tr -d ' ')"
fi

uncommitted_source="$(git status --porcelain -- ':!.docs/ai/**' 2>/dev/null | wc -l | tr -d ' ')"
uncommitted_doc="$(git status --porcelain -- "$current_state" 2>/dev/null | wc -l | tr -d ' ')"

should_fire=false
if [ "$session_source_commits" -gt 0 ] && [ "$session_doc_commits" -eq 0 ] && [ "$uncommitted_doc" -eq 0 ]; then
  should_fire=true
fi
if [ "$uncommitted_source" -gt 0 ] && [ "$uncommitted_doc" -eq 0 ]; then
  should_fire=true
fi

[ "$should_fire" = true ] || exit 0

[ -n "$fired_flag" ] && : > "$fired_flag"

cat <<EOF
AI handoff drift: this session changed source files without updating .docs/ai/current-state.md.

- Source-touching commits this session: ${session_source_commits}
- Uncommitted non-doc files: ${uncommitted_source}

Per AGENTS.md (Session End): before stopping, update .docs/ai/current-state.md with recent progress, blockers, and build status. If any non-obvious design or tooling decision was made, append to .docs/ai/decisions.md. Check off any completed Now/Next items in .docs/ai/roadmap.md.
EOF
exit 2
