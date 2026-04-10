#!/bin/sh
sketchybar --add item cal right                                \
                 --set cal script="printf '%s\n' $(cal)        \
                 update_freq=3600                              \
                 background.color=$COLOR_PURPLE                \
                 label.color=$COLOR_BACKGROUND                 \
                 icon.color=$COLOR_BACKGROUND                  \
                 label.font="$FONT:Semibold:6"                 \
