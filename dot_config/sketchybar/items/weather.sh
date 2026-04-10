#!/bin/sh
sketchybar --add item weather right                            \
           --set weather script="$PLUGIN_DIR/weather.sh"       \
                         update_freq=600                       \
                         background.color=$COLOR_CYAN          \
                         label.color=$COLOR_BACKGROUND         \
                         icon.color=$COLOR_BACKGROUND          \
                         # label.font="$FONT:Bold:14.0"          \

# weather=(
#   script="$PLUGIN_DIR/weather.sh"
#   update_freq=600
#   label.font="$FONT:Bold:14.0"
# )
#
# sketchybar --add item weather right      \
#            --set weather "${weather[@]}" \
