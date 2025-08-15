
#!/bin/bash

# Source library files
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/get_window_id_by_app.sh"
source "$SCRIPT_DIR/lib/get_window_id_by_app_and_project.sh"

# Configuration constants
MAIN_MONITOR_WORKSPACE=5
SECOND_MONITOR_WORKSPACE=6

# move-node-to-workspace

GODOT_ID=$(aerospace_helpers_get_window_id_by_app "Godot")
CURSOR_ID=$(aerospace_helpers_get_window_id_by_app_and_project "Cursor" "~/dev/godot")

echo "GODOT_ID: $GODOT_ID"
echo "CURSOR_ID: $CURSOR_ID"

MONITOR_COUNT=$(aerospace list-monitors | wc -l)
if [ "$MONITOR_COUNT" -gt 1 ]; then
        # Multi-monitor: switch between main and secondary monitor workspaces
        aerospace move-node-to-workspace --window-id $GODOT_ID $SECOND_MONITOR_WORKSPACE
        sleep 0.1
        aerospace move-node-to-workspace --window-id $CURSOR_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        aerospace workspace $SECOND_MONITOR_WORKSPACE
        sleep 0.1
        aerospace workspace $MAIN_MONITOR_WORKSPACE
    else
        # Single monitor: just switch between main workspaces
        aerospace move-node-to-workspace --window-id $GODOT_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        aerospace move-node-to-workspace --window-id $CURSOR_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        aerospace layout --window-id $GODOT_ID accordion
        aerospace layout --window-id $CURSOR_ID accordion
        sleep 0.1
        aerospace workspace $MAIN_MONITOR_WORKSPACE
    fi