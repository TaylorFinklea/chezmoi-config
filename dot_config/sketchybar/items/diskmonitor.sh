#!/bin/bash

diskmonitor=(
  icon.font="CaskaydiaCove Nerd Font Mono:Regular:14"
  icon.padding_right=20
  label.drawing=off
  y_offset=1
  update_freq=360
  updates=when_shown
  script="$PLUGIN_DIR/diskmonitor.sh"
)

misc=(
  icon.drawing=off
  width=0
  padding_right=4
  update_freq=360
  updates=when_shown
)

diskmonitor_label=(
  "${misc[@]}"
  label.font="$FONT:Semibold:8"
  label.color=$COLOR_BACKGROUND
  label=SSD
  y_offset=5
)

diskmonitor_value=(
  "${misc[@]}"
  label.font="$FONT:Bold:8"
  label.color=$COLOR_BACKGROUND
  y_offset=-3
)

sketchybar                                          \
  --add item diskmonitor.label right                \
  --set diskmonitor.label "${diskmonitor_label[@]}" \
                                                    \
  --add item diskmonitor.value right                \
  --set diskmonitor.value "${diskmonitor_value[@]}" \
                                                    \
  --add item diskmonitor right                      \
  --set diskmonitor "${diskmonitor[@]}"             \
  --subscribe diskmonitor mouse.clicked
