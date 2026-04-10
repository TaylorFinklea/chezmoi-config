#!/bin/sh
sketchybar --add item clock right                            \
           --set clock script="$PLUGIN_DIR/clock.sh" padding_right=1 background.drawing=1 icon.background.drawing=1 icon.color=$COLOR_BACKGROUND icon.padding_left=4 icon.padding_right=1 label.padding_left=5 label.padding_right=1 background.color=$COLOR_BACKGROUND label.font.size=12.5 update_freq=1 label.font.style="Bold" label.color=$COLOR_CYAN 
