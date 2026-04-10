           # COLORS_SPACE=($COLOR_MAGENTA $COLOR_VIOLET $COLOR_LIGHTBLUE $COLOR_SEAFOAM $COLOR_CYAN $COLOR_GREEN $COLOR_YELLOW $COLOR_ORANGE $COLOR_RED $COLOR_PINK)
           # LENGTH=${#ICONS_SPACE[@]}

           # for i in "${!ICONS_SPACE[@]}"
           # do
           #   sid=$(($i+1))
           #   PAD_LEFT=2
           #   PAD_RIGHT=2
           #   if [[ $i == 0 ]]; then
           #     PAD_LEFT=8
           #   elif [[ $i == $(($LENGTH-1)) ]]; then
           #     PAD_RIGHT=8
           #   fi
           #   sketchybar --add space space.$sid left                                       \
           #              --set       space.$sid script="$PLUGIN_DIR/app_space2.sh"          \
           #                                     associated_space=$sid                      \
           #                                     padding_left=$PAD_LEFT                     \
           #                                     padding_right=$PAD_RIGHT                   \
           #                                     background.color=${COLORS_SPACE[i]}        \
           #                                     background.border_width=0                  \
           #                                     background.corner_radius=6                 \
           #                                     background.height=24                       \
           #                                     icon=${ICONS_SPACE[i]}                     \
           #                                     icon.color=${COLORS_SPACE[i]}              \
           #                                     label="_"                                  \
           #                                     label.font="sketchybar-app-font:Regular:16.0"            \
           #                                     icon.font="$FONT:Regular:16.0"             \
           #                                     label.color=${COLORS_SPACE[i]}             \
           #              --subscribe space.$sid front_app_switched window_change
           # done

           # spaces_bracket=(
           #   background.color=$BAR_COLOR
           #   background.border_color=$BAR_BORDER_COLOR
           # )

           # separator=(
           #   icon=
           #   icon.font="$FONT:Bold:16.0"
           #   padding_left=10
           #   padding_right=8
           #   label.drawing=off
           #   associated_display=active
           #   click_script='yabai -m space --create && sketchybar --trigger space_change'
           #   icon.color=$COLOR_SEAFOAM
           # )

           # sketchybar --add bracket spaces_bracket '/space\..*/'  \
           #            --set spaces_bracket "${spaces_bracket[@]}" \
           #                                                        \
           #            --add item separator left                   \
           #            --set separator "${separator[@]}"

COLORS_SPACE=($COLOR_MAGENTA $COLOR_VIOLET $COLOR_LIGHTBLUE $COLOR_SEAFOAM $COLOR_CYAN $COLOR_GREEN $COLOR_YELLOW $COLOR_ORANGE $COLOR_RED $COLOR_PINK)

sketchybar --add event aerospace_workspace_change \
            --add event window_change \
            --add event front_app_switched

# Add items for each workspace
for sid in $(aerospace list-workspaces --all); do
    # Calculate color index
    COLOR_INDEX=$(( (sid - 1) % ${#COLORS_SPACE[@]} ))

    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change window_change front_app_switched \
        --set space.$sid \
        background.color="${COLORS_SPACE[$COLOR_INDEX]}" \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=off \
        drawing=on \
        label="$sid" \
        label.font="sketchybar-app-font:Regular:16.0" \
        icon.font="$FONT:Regular:16.0" \
        label.color="${COLORS_SPACE[$COLOR_INDEX]}" \
        click_script="aerospace workspace $sid" \
        script="$PLUGIN_DIR/app_space2.sh"

    # Initial run of the script to set correct visibility
    "$PLUGIN_DIR/app_space2.sh" "space.$sid"
done
