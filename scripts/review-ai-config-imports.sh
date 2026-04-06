#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

REPORT_PATH="$REPO_ROOT/.docs/ai/import-review.md"

usage() {
    cat <<'EOF'
Review home-directory AI config changes before importing them into this repo.

Usage:
  ./scripts/review-ai-config-imports.sh [--report PATH]

Options:
  --report PATH  Write the markdown report to PATH.
  -h, --help     Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --report)
            REPORT_PATH="$2"
            shift 2
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

CLAUDE_ROOT="$HOME/.claude"
CODEX_ROOT="$HOME/.codex"
COPILOT_ROOT="$HOME/.copilot"
AGENTS_ROOT="$HOME/.agents"

SAFE_ITEMS=()
REVIEW_ITEMS=()
BLOCKED_ITEMS=()
IGNORED_ITEMS=()

record_item() {
    local bucket="$1"
    local message="$2"
    case "$bucket" in
        safe) SAFE_ITEMS+=("$message") ;;
        review) REVIEW_ITEMS+=("$message") ;;
        blocked) BLOCKED_ITEMS+=("$message") ;;
        ignored) IGNORED_ITEMS+=("$message") ;;
        *) echo "Unknown bucket: $bucket" >&2; exit 1 ;;
    esac
}

display_home_path() {
    local path="$1"
    if [[ "$path" == "$HOME/"* ]]; then
        printf '~/%s' "${path#$HOME/}"
    else
        printf '%s' "$path"
    fi
}

display_repo_path() {
    local path="$1"
    if [[ "$path" == "$REPO_ROOT/"* ]]; then
        printf '%s' "${path#$REPO_ROOT/}"
    else
        printf '%s' "$path"
    fi
}

same_content() {
    local src="$1"
    local dest="$2"
    diff -qr "$src" "$dest" >/dev/null 2>&1
}

review_repo_managed_file() {
    local src="$1"
    local dest="$2"
    local label="$3"
    if [[ ! -f "$src" || ! -f "$dest" ]]; then
        return 0
    fi
    if ! cmp -s "$src" "$dest"; then
        record_item blocked "$label differs: '$(display_home_path "$src")' must not overwrite repo-managed '$(display_repo_path "$dest")'."
    fi
}

note_machine_local_file() {
    local src="$1"
    local label="$2"
    if [[ -f "$src" ]]; then
        record_item ignored "$label is machine-local and intentionally not imported automatically: '$(display_home_path "$src")'."
    fi
}

should_skip_top_level() {
    local root_key="$1"
    local name="$2"
    case "$name" in
        audit-backlog|process-backlog|process-backlog-opus|resume-and-continue|import-ai-config-changes)
            return 0
            ;;
    esac

    case "$root_key" in
        codex-skills)
            case "$name" in
                .system|security-ownership-map)
                    return 0
                    ;;
            esac
            ;;
    esac

    return 1
}

review_additive_dir() {
    local root_key="$1"
    local src_root="$2"
    local dest_root="$3"

    if [[ ! -d "$src_root" ]]; then
        return 0
    fi

    while IFS= read -r -d '' child; do
        local base
        local dest_child
        base="$(basename "$child")"

        if should_skip_top_level "$root_key" "$base"; then
            record_item ignored "Managed or ignored path skipped: '$(display_home_path "$child")'."
            continue
        fi

        dest_child="$dest_root/$base"
        if [[ ! -e "$dest_child" ]]; then
            record_item safe "New top-level addition: '$(display_home_path "$child")' -> '$(display_repo_path "$dest_child")'."
            continue
        fi

        if ! same_content "$child" "$dest_child"; then
            record_item review "Tracked path differs and needs review before import: '$(display_home_path "$child")' vs '$(display_repo_path "$dest_child")'."
        fi
    done < <(find "$src_root" -mindepth 1 -maxdepth 1 -print0)
}

review_mapped_file() {
    local src="$1"
    local dest="$2"
    if [[ ! -f "$src" ]]; then
        return 0
    fi

    if [[ ! -e "$dest" ]]; then
        record_item safe "New mapped file addition: '$(display_home_path "$src")' -> '$(display_repo_path "$dest")'."
        return 0
    fi

    if ! cmp -s "$src" "$dest"; then
        record_item review "Tracked mapped file differs and needs review before import: '$(display_home_path "$src")' vs '$(display_repo_path "$dest")'."
    fi
}

render_section() {
    local title="$1"
    shift
    local items=("$@")

    echo "## $title"
    if [[ ${#items[@]} -eq 0 ]]; then
        echo
        echo "- (none)"
        echo
        return 0
    fi

    echo
    local item
    for item in "${items[@]}"; do
        echo "- $item"
    done
    echo
}

mkdir -p "$(dirname "$REPORT_PATH")"

review_repo_managed_file "$HOME/AGENTS.md" "$REPO_ROOT/AGENTS.md" "Repo-managed shared agent instructions"
review_repo_managed_file "$HOME/CLAUDE.md" "$REPO_ROOT/CLAUDE.md" "Repo-managed Claude instructions"
review_repo_managed_file "$CODEX_ROOT/AGENTS.md" "$REPO_ROOT/dot_codex/AGENTS.md" "Repo-managed Codex instructions"
review_repo_managed_file "$COPILOT_ROOT/copilot-instructions.md" "$REPO_ROOT/dot_copilot/copilot-instructions.md" "Repo-managed Copilot instructions"

note_machine_local_file "$CODEX_ROOT/config.toml" "Codex config"

review_additive_dir "claude-agents" "$CLAUDE_ROOT/agents" "$REPO_ROOT/dot_claude/agents"
review_additive_dir "claude-skills" "$CLAUDE_ROOT/skills" "$REPO_ROOT/dot_claude/skills"
review_additive_dir "claude-templates" "$CLAUDE_ROOT/templates" "$REPO_ROOT/dot_claude/templates"
review_additive_dir "codex-skills" "$CODEX_ROOT/skills" "$REPO_ROOT/dot_codex/skills"
review_additive_dir "copilot-skills" "$COPILOT_ROOT/skills" "$REPO_ROOT/dot_copilot/skills"
review_additive_dir "agents-skills" "$AGENTS_ROOT/skills" "$REPO_ROOT/dot_agents/skills"

review_mapped_file \
    "$CODEX_ROOT/skills/spreadsheet/references/examples/openpyxl/basic_spreadsheet.py" \
    "$REPO_ROOT/dot_codex/skills/spreadsheet/references/examples/openpyxl/create_basic_spreadsheet.py"
review_mapped_file \
    "$CODEX_ROOT/skills/spreadsheet/references/examples/openpyxl/spreadsheet_with_styling.py" \
    "$REPO_ROOT/dot_codex/skills/spreadsheet/references/examples/openpyxl/create_spreadsheet_with_styling.py"
review_mapped_file \
    "$CODEX_ROOT/skills/weekly-meal-planner/scripts/template.py" \
    "$REPO_ROOT/dot_codex/skills/weekly-meal-planner/scripts/create_template.py"

{
    echo "# AI Config Import Review"
    echo
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo
    echo "## Summary"
    echo
    echo "- Safe additions: ${#SAFE_ITEMS[@]}"
    echo "- Review required: ${#REVIEW_ITEMS[@]}"
    echo "- Blocked: ${#BLOCKED_ITEMS[@]}"
    echo "- Ignored: ${#IGNORED_ITEMS[@]}"
    echo
    render_section "Safe Additions" "${SAFE_ITEMS[@]}"
    render_section "Review Required" "${REVIEW_ITEMS[@]}"
    render_section "Blocked" "${BLOCKED_ITEMS[@]}"
    render_section "Ignored" "${IGNORED_ITEMS[@]}"
    echo "## Recommended Next Step"
    echo
    if [[ ${#BLOCKED_ITEMS[@]} -gt 0 || ${#REVIEW_ITEMS[@]} -gt 0 ]]; then
        echo "- Do not run the importer blindly. Review the flagged paths first."
        echo '- If you only want safe additions, keep the flagged paths untouched and run `./scripts/sync-ai-configs.sh --dry-run`.'
    else
        echo '- Safe additions only. Run `./scripts/sync-ai-configs.sh --dry-run`, then `./scripts/sync-ai-configs.sh` if the output still matches this report.'
    fi
    echo
} >"$REPORT_PATH"

cat "$REPORT_PATH"
