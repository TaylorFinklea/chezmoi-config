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
    # Window-status formats and styles are unified globally in dot_tmux.conf —
    # the slot is plain ` #I:#W ` (with optional ` ● ` pin prefix) and the bg
    # comes from window-status-style / -current-style, parser-friendly in both
    # modes. So Moshi mode only needs to blank the sides.
    tmux set -g status-left ''
    tmux set -g status-right ''
    tmux set -g @moshi_active 1
}

restore_status() {
    local sl sr
    sl=$(tmux show-options -gv @local_status_left  2>/dev/null || true)
    sr=$(tmux show-options -gv @local_status_right 2>/dev/null || true)
    tmux set -g status-left "$sl"
    tmux set -g status-right "$sr"
    tmux set -g @moshi_active 0
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
    preserve)
        # Reapply whichever mode is currently active (read from @moshi_active).
        # Used after `source-file ~/.tmux.conf` so a manual `toggle` into Moshi
        # mode survives a config reload — the conf re-sets status-left/right
        # and the window formats to their local-mode values, which clobbers an
        # active blank_status. This re-runs the matching helper.
        current=$(tmux show-options -gv @moshi_active 2>/dev/null || echo 0)
        if [ "$current" = "1" ]; then blank_status; else restore_status; fi
        ;;
    *)
        echo "Usage: $0 {apply|toggle|preserve}" >&2
        exit 1
        ;;
esac
