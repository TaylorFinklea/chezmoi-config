#!/bin/bash
# SessionStart hook: inject .docs/ai/ freshness summary as additionalContext.
#
# Must NOT be async in settings.json — async hooks have their stdout discarded,
# and we rely on stdout being parsed for the hook JSON output.
#
# Also drops a session-start marker (HEAD SHA) under ~/.cache/claude-handoff/
# so the companion Stop rewake hook can detect drift created during this session.

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

session_id="$(printf '%s' "$input" | "$JQ" -r '.session_id // empty' 2>/dev/null || true)"
state_dir="$HOME/.cache/claude-handoff"
mkdir -p "$state_dir" 2>/dev/null || true
find "$state_dir" -type f -mtime +30 -delete 2>/dev/null || true

if [ -n "$session_id" ]; then
  git rev-parse HEAD > "$state_dir/${session_id}.start" 2>/dev/null || true
fi

last_doc_commit="$(git log -1 --format='%H' -- "$current_state" 2>/dev/null || true)"
if [ -z "$last_doc_commit" ]; then
  context="AI handoff: .docs/ai/current-state.md exists but has no committed history. Per AGENTS.md, treat it as the durable session breadcrumb."
else
  days_stale="$(git log -1 --format='%cr' "$last_doc_commit" 2>/dev/null || echo 'unknown')"
  source_commits="$(git log --oneline "${last_doc_commit}..HEAD" -- ':!.docs/ai/**' 2>/dev/null | wc -l | tr -d ' ')"
  uncommitted_source="$(git status --porcelain -- ':!.docs/ai/**' 2>/dev/null | wc -l | tr -d ' ')"
  uncommitted_doc="$(git status --porcelain -- "$current_state" 2>/dev/null | wc -l | tr -d ' ')"

  context="AI handoff freshness — .docs/ai/current-state.md last updated ${days_stale}. Since then: ${source_commits} source-touching commits, ${uncommitted_source} uncommitted non-doc files, ${uncommitted_doc} uncommitted current-state.md change(s). Per AGENTS.md: read .docs/ai/{roadmap,current-state,decisions}.md at session start and update them at session end."
fi

"$JQ" -nc --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
