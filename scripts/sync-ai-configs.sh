#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DRY_RUN=0

usage() {
    cat <<'EOF'
Sync global Claude, Codex, and Copilot instruction/config content into this chezmoi repo.

Usage:
  ./scripts/sync-ai-configs.sh [--dry-run]

Options:
  --dry-run   Show what would change without modifying files.
  -h, --help  Show this help text.
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

require_file() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        echo "Missing required file: $path" >&2
        exit 1
    fi
}

require_dir() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        echo "Missing required directory: $path" >&2
        exit 1
    fi
}

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required but not installed." >&2
    exit 1
fi

CLAUDE_ROOT="$HOME/.claude"
CODEX_ROOT="$HOME/.codex"
COPILOT_ROOT="$HOME/.copilot"
AGENTS_ROOT="$HOME/.agents"

require_file "$HOME/AGENTS.md"
require_file "$HOME/CLAUDE.md"
require_file "$CODEX_ROOT/AGENTS.md"
require_file "$CODEX_ROOT/config.toml"
require_dir "$CODEX_ROOT/skills"
require_dir "$AGENTS_ROOT/skills"

RSYNC_BASE=(-a --checksum --delete --itemize-changes)
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

sync_file "$HOME/AGENTS.md" "$REPO_ROOT/AGENTS.md"
sync_file "$HOME/CLAUDE.md" "$REPO_ROOT/CLAUDE.md"
sync_file "$CODEX_ROOT/AGENTS.md" "$REPO_ROOT/dot_codex/AGENTS.md"
sync_optional_file "$COPILOT_ROOT/copilot-instructions.md" "$REPO_ROOT/dot_copilot/copilot-instructions.md"
sync_file "$CODEX_ROOT/config.toml" "$REPO_ROOT/dot_codex/private_config.toml"
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
    --delete-excluded \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_optional_dir "$CLAUDE_ROOT/templates" "$REPO_ROOT/dot_claude/templates" \
    --delete-excluded \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_dir "$CODEX_ROOT/skills" "$REPO_ROOT/dot_codex/skills" \
    --delete-excluded \
    --exclude '.system/' \
    --exclude 'security-ownership-map/' \
    --exclude 'spreadsheet/references/examples/openpyxl/basic_spreadsheet.py' \
    --exclude 'spreadsheet/references/examples/openpyxl/spreadsheet_with_styling.py' \
    --exclude 'weekly-meal-planner/scripts/template.py' \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude '*.pyo'
sync_dir "$AGENTS_ROOT/skills" "$REPO_ROOT/dot_agents/skills" \
    --delete-excluded \
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
