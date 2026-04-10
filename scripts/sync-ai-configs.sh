#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPORT_PATH="$REPO_ROOT/.docs/ai/import-review.md"

usage() {
    cat <<'EOF'
Review local AI config drift without importing it into managed trees.

Usage:
  ./scripts/sync-ai-configs.sh [--report PATH]

Options:
  --report PATH  Write the markdown review report to PATH.
  -h, --help     Show this help text.

Notes:
  - This command is intentionally report-only.
  - Managed AI config now flows through discovery -> inbox promotion -> chezmoi.
  - To stage a local path for review, use ./scripts/promote-ai-config-inbox.sh.
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

echo "Repo root: $REPO_ROOT"
echo "Mode: review-only"
echo

"$SCRIPT_DIR/review-ai-config-imports.sh" --report "$REPORT_PATH"

echo
echo "No managed files were imported."
echo "To stage a local path for classification, run:"
echo "  ./scripts/promote-ai-config-inbox.sh --source <path> --slug <name> --scope <shared|work-only|personal-only> --targets <comma-separated-tools>"
