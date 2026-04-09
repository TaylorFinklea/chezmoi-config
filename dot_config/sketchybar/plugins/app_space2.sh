#!/bin/sh
source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

# Add the path to aerospace (replace with your actual path)
AEROSPACE_PATH="/opt/homebrew/bin/aerospace"  # or wherever your aerospace is installed

# Color array
COLORS_SPACE=($COLOR_MAGENTA $COLOR_VIOLET $COLOR_LIGHTBLUE $COLOR_SEAFOAM $COLOR_CYAN $COLOR_GREEN $COLOR_YELLOW $COLOR_ORANGE $COLOR_RED $COLOR_PINK)

# Get the workspace ID from the item name
WORKSPACE_ID=$(echo "$NAME" | cut -d'.' -f2)

echo "COLORS_SPACE length: ${#COLORS_SPACE[@]}"
echo "WORKSPACE_ID: $WORKSPACE_ID"

# Calculate color index
COLOR_INDEX=$(( (WORKSPACE_ID - 1) % ${#COLORS_SPACE[@]} ))
WORKSPACE_COLOR="${COLORS_SPACE[$COLOR_INDEX]}"

# Get windows for this specific workspace
WINDOWS=$($AEROSPACE_PATH list-windows --workspace "$WORKSPACE_ID" --format "%{app-name}")

# Initialize empty label
LABEL="$WORKSPACE_ID"
if [ -n "$WINDOWS" ]; then
    # Process each window in the workspace
    while IFS= read -r APP_NAME; do
        if [ -n "$APP_NAME" ]; then
            # Get icon for the app
            ICON=$($HOME/.config/sketchybar/plugins/app_icon.sh "$APP_NAME")

            # Add space between icons if not the first icon
            if [ "$LABEL" = "$WORKSPACE_ID" ]; then
                LABEL+=" $ICON"
            else
                LABEL+=" $ICON"
            fi
        fi
    done <<< "$WINDOWS"
    # Show the item if workspace has windows
    sketchybar --set "$NAME" drawing=on
else
    # Hide the item if workspace is empty
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Update the space item with the new label
sketchybar --set "$NAME" label="$LABEL"

# Update background based on if workspace is focused
IS_FOCUSED=$($AEROSPACE_PATH list-workspaces --all | grep "^$WORKSPACE_ID " | grep -q "true$" && echo "true" || echo "false")
if [ "$IS_FOCUSED" = "true" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on \
        background.color="$WORKSPACE_COLOR" \
        label.color=0xff000000  # Black text for contrast
else
    sketchybar --set "$NAME" \
        background.drawing=off \
        label.color="$WORKSPACE_COLOR"  # Use workspace color for text when not focused
fi
