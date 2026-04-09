#!/bin/sh
sketchybar --add item network right                            \
           --set network script="$PLUGIN_DIR/network.sh"       \
                 update_freq=10                                \
                 background.color=$COLOR_PURPLE                \
                 label.color=$COLOR_BACKGROUND                 \
                 icon.color=$COLOR_BACKGROUND                  \
