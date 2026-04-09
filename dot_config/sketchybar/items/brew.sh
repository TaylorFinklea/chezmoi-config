#!/bin/bash

# Trigger the brew_udpate event when brew update or upgrade is run from cmdline
# e.g. via function in .zshrc

brew=(
  icon=
  label=?
  padding_right=10
  script="$PLUGIN_DIR/brew.sh"
  label.color=$COLOR_BACKGROUND
  icon.color=$COLOR_BACKGROUND
  background.color=$COLOR_SEAFOAM
)

sketchybar --add event brew_update \
           --add item brew right   \
           --set brew "${brew[@]}" \
           --subscribe brew brew_update

