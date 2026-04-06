#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DRY_RUN=0

usage() {
    cat <<'EOF'
Import additive home-directory skill and template content into this chezmoi repo
without overwriting repo-managed instruction files or machine-specific config.

Usage:
  ./scripts/sync-ai-configs.sh [--dry-run]

Options:
  --dry-run   Show what would change without modifying files.
  -h, --help  Show this help text.

Notes:
  - Repo-managed source-of-truth files such as AGENTS/CLAUDE/Codex instructions
    are edited in this repo and pushed to machines with `chezmoi apply`.
  - This script is intentionally conservative: it imports optional home-created
    skills, agents, and templates without deleting tracked repo content.
  - `~/.codex/config.toml` is not imported here because work/home machines may
    legitimately differ.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required but not installed." >&2
    exit 1
fi

CLAUDE_ROOT="$HOME/.claude"
CODEX_ROOT="$HOME/.codex"
COPILOT_ROOT="$HOME/.copilot"
AGENTS_ROOT="$HOME/.agents"

RSYNC_BASE=(-a --checksum --itemize-changes)
if [[ $DRY_RUN -eq 1 ]]; then
    RSYNC_BASE+=(-n)
fi

sync_file() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    echo "Sync file: ${src#$HOME/} -> ${dest#$REPO_ROOT/}"
    rsync "${RSYNC_BASE[@]}" "$src" "$dest"
}

sync_optional_file() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$src" ]]; then
        echo "Skip file: ${src#$HOME/} (not found)"
        return 0
    fi
    sync_file "$src" "$dest"
}

sync_optional_dir() {
    local src="$1"
    local dest="$2"
    shift 2
    if [[ ! -d "$src" ]]; then
        echo "Skip dir: ${src#$HOME/} (not found)"
        return 0
    fi
    sync_dir "$src" "$dest" "$@"
}

WORKFLOW_EXCLUDES=(
    --exclude 'audit-backlog/'
    --exclude 'process-backlog/'
    --exclude 'process-backlog-opus/'
    --exclude 'resume-and-continue/'
)

sync_dir() {
    local src="$1"
    local dest="$2"
    shift 2
    mkdir -p "$dest"
    echo "Sync dir: ${src#$HOME/} -> ${dest#$REPO_ROOT/}"
    rsync "${RSYNC_BASE[@]}" "$@" "$src/" "$dest/"
}

echo "Repo root: $REPO_ROOT"
if [[ $DRY_RUN -eq 1 ]]; then
    echo "Mode: dry-run"
else
    echo "Mode: apply"
fi
echo

echo "Repo-managed docs and instructions are not imported by this script."
echo "Use chezmoi apply to sync repo-managed files out to each machine."
echo

sync_optional_file \
    "$CODEX_ROOT/skills/spreadsheet/references/examples/openpyxl/basic_spreadsheet.py" \
    "$REPO_ROOT/dot_codex/skills/spreadsheet/references/examples/openpyxl/create_basic_spreadsheet.py"
sync_optional_file \
    "$CODEX_ROOT/skills/spreadsheet/references/examples/openpyxl/spreadsheet_with_styling.py" \
    "$REPO_ROOT/dot_codex/skills/spreadsheet/references/examples/openpyxl/create_spreadsheet_with_styling.py"
sync_optional_file \
    "$CODEX_ROOT/skills/weekly-meal-planner/scripts/template.py" \
    "$REPO_ROOT/dot_codex/skills/weekly-meal-planner/scripts/create_template.py"

sync_optional_dir "$CLAUDE_ROOT/agents" "$REPO_ROOT/dot_claude/agents"
sync_optional_dir "$CLAUDE_ROOT/skills" "$REPO_ROOT/dot_claude/skills" \
    -L \
    "${WORKFLOW_EXCLUDES[@]}" \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_optional_dir "$CLAUDE_ROOT/templates" "$REPO_ROOT/dot_claude/templates" \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_dir "$CODEX_ROOT/skills" "$REPO_ROOT/dot_codex/skills" \
    "${WORKFLOW_EXCLUDES[@]}" \
    --exclude '.system/' \
    --exclude 'security-ownership-map/' \
    --exclude 'spreadsheet/references/examples/openpyxl/basic_spreadsheet.py' \
    --exclude 'spreadsheet/references/examples/openpyxl/spreadsheet_with_styling.py' \
    --exclude 'weekly-meal-planner/scripts/template.py' \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_optional_dir "$COPILOT_ROOT/skills" "$REPO_ROOT/dot_copilot/skills" \
    "${WORKFLOW_EXCLUDES[@]}" \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_dir "$AGENTS_ROOT/skills" "$REPO_ROOT/dot_agents/skills" \
    "${WORKFLOW_EXCLUDES[@]}" \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'

echo
if [[ $DRY_RUN -eq 1 ]]; then
    echo "Dry run complete. Review the rsync output above."
else
    echo "Sync complete."
    echo "Changed files:"
    git -C "$REPO_ROOT" status --short
fi
