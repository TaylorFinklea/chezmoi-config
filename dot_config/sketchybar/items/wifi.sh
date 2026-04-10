#!/bin/bash

source "$CONFIG_DIR/icons.sh"

wifi=(
  padding_right=0
  padding_left=0
  label.width=0
  icon="$WIFI_DISCONNECTED"
  script="$PLUGIN_DIR/wifi.sh"
  label.color=$COLOR_BACKGROUND
  icon.color=$COLOR_BACKGROUND
  background.color=$COLOR_SEAFOAM
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change mouse.clicked
