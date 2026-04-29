#!/usr/bin/env bash
# Apply or toggle Moshi-mode status blanking based on tmux session env.
# Usage: moshi-status.sh apply   - auto-detect from MOSHI_CLIENT in any session
#        moshi-status.sh toggle  - manual flip (uses @moshi_active option)
#
# Paired with dot_tmux.conf hooks. Blanks status-left/right when a Moshi
# client is attached (its session env carries MOSHI_CLIENT via tmux's
# update-environment) so Moshi's swipe-to-change-window gesture can parse
# the status bar reliably. Restores @local_status_left/right when no Moshi
# clients remain.
set -eu

blank_status() {
    tmux set -g status-left  '' \; set -g status-right '' \; set -g @moshi_active 1
}

restore_status() {
    local sl sr
    sl=$(tmux show-options -gv @local_status_left  2>/dev/null || true)
    sr=$(tmux show-options -gv @local_status_right 2>/dev/null || true)
    tmux set -g status-left  "$sl" \; set -g status-right "$sr" \; set -g @moshi_active 0
}

# tmux show-environment prints `-MOSHI_CLIENT` for the explicitly-unset form
# (the marker update-environment leaves when the var was absent at attach).
# Filtering with `^MOSHI_CLIENT=` matches only the present-and-set form.
any_session_has_moshi() {
    local s
    while IFS= read -r s; do
        if tmux show-environment -t "$s" MOSHI_CLIENT 2>/dev/null | grep -q '^MOSHI_CLIENT='; then
            return 0
        fi
    done < <(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)
    return 1
}

case "${1:-apply}" in
    apply)
        if any_session_has_moshi; then blank_status; else restore_status; fi
        ;;
    toggle)
        current=$(tmux show-options -gv @moshi_active 2>/dev/null || echo 0)
        if [ "$current" = "1" ]; then restore_status; else blank_status; fi
        ;;
    *)
        echo "Usage: $0 {apply|toggle}" >&2
        exit 1
        ;;
esac
