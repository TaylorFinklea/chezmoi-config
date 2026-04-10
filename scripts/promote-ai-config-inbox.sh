#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INBOX_ROOT="$REPO_ROOT/.docs/ai/inbox"

SOURCE=""
SLUG=""
SCOPE=""
TARGETS=""
KIND="skill"
NOTES=""

usage() {
    cat <<'EOF'
Stage a local AI artifact into the repo inbox for scope classification.

Usage:
  ./scripts/promote-ai-config-inbox.sh --source PATH --slug NAME --scope SCOPE --targets codex,opencode [options]

Options:
  --source PATH   Local file or directory to stage.
  --slug NAME     Stable inbox slug.
  --scope SCOPE   One of: shared, work-only, personal-only.
  --targets LIST  Comma-separated tool targets, for example: codex,copilot,opencode.
  --kind KIND     Artifact kind. Default: skill.
  --notes TEXT    Optional free-form note recorded in metadata.
  -h, --help      Show this help text.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)
            SOURCE="$2"
            shift 2
            ;;
        --slug)
            SLUG="$2"
            shift 2
            ;;
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        --targets)
            TARGETS="$2"
            shift 2
            ;;
        --kind)
            KIND="$2"
            shift 2
            ;;
        --notes)
            NOTES="$2"
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

if [[ -z "$SOURCE" || -z "$SLUG" || -z "$SCOPE" || -z "$TARGETS" ]]; then
    usage >&2
    exit 1
fi

case "$SCOPE" in
    shared|work-only|personal-only) ;;
    *)
        echo "Invalid scope: $SCOPE" >&2
        exit 1
        ;;
esac

if [[ ! -e "$SOURCE" ]]; then
    echo "Source not found: $SOURCE" >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required but not installed." >&2
    exit 1
fi

INBOX_DIR="$INBOX_ROOT/$SLUG"
SOURCE_DIR="$INBOX_DIR/source"

mkdir -p "$SOURCE_DIR"
rm -rf "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR"

if [[ -d "$SOURCE" ]]; then
    rsync -a "$SOURCE"/ "$SOURCE_DIR/"
else
    rsync -a "$SOURCE" "$SOURCE_DIR/"
fi

cat >"$INBOX_DIR/metadata.json" <<EOF
{
  "slug": "$SLUG",
  "kind": "$KIND",
  "scope": "$SCOPE",
  "targets": [$(printf '"%s"' "${TARGETS//,/\",\"}")],
  "source_path": "$SOURCE",
  "notes": $(python3 - <<'PY' "$NOTES"
import json, sys
print(json.dumps(sys.argv[1]))
PY
)
}
EOF

cat >"$INBOX_DIR/README.md" <<EOF
# Inbox: $SLUG

- Kind: $KIND
- Scope: $SCOPE
- Targets: $TARGETS
- Source: $SOURCE

Review the staged content in \`source/\`, then move it into a managed location only
after deciding whether it belongs in shared, work-only, or personal-only config.
EOF

echo "Staged inbox entry at: $INBOX_DIR"
