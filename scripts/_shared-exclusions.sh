#!/usr/bin/env bash
# Shared exclusion lists and helper used by sync-ai-configs.sh and
# review-ai-config-imports.sh.  Source this file; do not execute it directly.

MANAGED_WORKFLOW_SKILLS=(
    audit-backlog
    process-backlog
    process-backlog-opus
    resume-and-continue
    import-ai-config-changes
    phase-execution
)

CODEX_EXTRA_SKIP=(
    .system
    security-ownership-map
)

# is_managed_skill ROOT_KEY BASENAME
# Returns 0 (true) if the path should be skipped, 1 (false) otherwise.
is_managed_skill() {
    local root_key="$1"
    local name="$2"

    local skill
    for skill in "${MANAGED_WORKFLOW_SKILLS[@]}"; do
        if [[ "$name" == "$skill" ]]; then
            return 0
        fi
    done

    if [[ "$root_key" == "codex-skills" ]]; then
        local extra
        for extra in "${CODEX_EXTRA_SKIP[@]}"; do
            if [[ "$name" == "$extra" ]]; then
                return 0
            fi
        done
    fi

    return 1
}
