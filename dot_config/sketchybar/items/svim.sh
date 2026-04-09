#!/usr/bin/env sh

sketchybar --add item svim.mode right \
           --set svim.mode popup.align=right \
                           icon= \
                           icon.font="Hack Nerd Font Mono:Bold:28.0" \
                           label.font="Hack Nerd Font Mono:Bold:13.0" \
                           icon.color=0xffff6578 \
                           script="sketchybar --set svim.mode popup.drawing=off" \
           --subscribe svim.mode front_app_switched window_focus \
           --add item svim.cmdline popup.svim.mode \
           --set svim.cmdline icon="Command: "

