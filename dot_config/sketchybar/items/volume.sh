#!/bin/bash

volume_slider=(
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  label.drawing=off
  icon.drawing=off
  slider.highlight_color=$COLOR_BLUE
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color=$COLOR_BACKGROUND2
  slider.knob=􀀁
  slider.knob.drawing=on
)

volume_icon=(
  click_script="$PLUGIN_DIR/volume_click.sh"
  padding_left=10
  icon=$VOLUME_100
  icon.width=0
  icon.align=left
  icon.color=$COLOR_BACKGROUND
  icon.font="$FONT:Regular:14.0"
  label.width=25
  label.align=left
  label.font="$FONT:Regular:14.0"
)

status_bracket=(
  background.color=$COLOR_SEAFOAM
  background.border_color=$COLOR_BACKGROUND2
)

sketchybar --add slider volume right            \
           --set volume "${volume_slider[@]}"   \
           background.color=$COLOR_SEAFOAM      \
           label.color=$COLOR_BACKGROUND        \
           icon.color=$COLOR_BACKGROUND         \
           --subscribe volume volume_change     \
                              mouse.clicked     \
                              mouse.entered     \
                              mouse.exited      \
                                                \
           --add item volume_icon right         \
           --set volume_icon "${volume_icon[@]}"

sketchybar --add bracket status brew wifi volume_icon \
           --set status "${status_bracket[@]}"
