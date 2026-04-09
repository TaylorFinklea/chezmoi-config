#!/bin/bash

source "$CONFIG_DIR/colors.sh"

COUNT="$(/opt/homebrew/bin/brew outdated | wc -l | tr -d ' ')"

COLOR=$COLOR_RED

case "$COUNT" in
  [3-5][0-9]) COLOR=$COLOR_RED
  ;;
  [1-2][0-9]) COLOR=$COLOR_ORANGE
  ;;
  [1-9]) COLOR=$COLOR_YELLOW
  ;;
  0) COLOR=$COLOR_BACKGROUND
     COUNT=
  ;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR
