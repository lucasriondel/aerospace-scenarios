
#!/bin/bash

MAIN_MONITOR_WORKSPACE=5
SECOND_MONITOR_WORKSPACE=6

# Function to get window ID by app name
# Usage: get_window_id_by_app "app_name"
# Returns: window ID if found, empty string if not found
get_window_id_by_app() {
    local app_name="$1"

    
    if [ -z "$app_name" ]; then
        echo "Usage: get_window_id_by_app <app_name>" >&2
        return 1
    fi
    
    # Get aerospace window list and find matching app
    local window_id=$(aerospace list-windows --all | grep "$app_name" | head -1 | cut -d'|' -f1 | tr -d ' ')
    
    echo "$window_id"
}

# Function to get window ID by app name and project folder match
# Usage: get_window_id_by_app_and_project "app_name" "project_path"
# Returns: window ID if found and project matches, empty string if not found
get_window_id_by_app_and_project() {
    local app_name="$1"
    local project_path="$2"
    
    if [ -z "$app_name" ] || [ -z "$project_path" ]; then
        echo "Usage: get_window_id_by_app_and_project <app_name> <project_path>" >&2
        return 1
    fi
    
    # Check if helper script exists and is executable
    local helper_script="./is_window_corresponds_to_project_folder.sh"
    if [ ! -f "$helper_script" ]; then
        echo "Error: Helper script not found at '$helper_script'" >&2
        return 1
    fi
    if [ ! -x "$helper_script" ]; then
        echo "Error: Helper script not executable" >&2
        return 1
    fi
    
    # Get aerospace window list and filter by app
    local filtered_windows=$(aerospace list-windows --all | grep "$app_name")
    
    # Check each window for project match - avoid subshell by using array
    local window_id=""
    local line_count=0
    
    # Read lines into an array to avoid subshell issues (compatible with older bash)
    local -a lines
    local line_count_2=0
    
    # Use a temporary file to avoid process substitution issues
    local temp_file=$(mktemp)
    echo "$filtered_windows" > "$temp_file"
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            lines[$line_count_2]="$line"
            line_count_2=$((line_count_2 + 1))
        fi
    done < "$temp_file"
    
    # Clean up temp file
    rm "$temp_file"
    
    # Iterate over array elements
    for ((i=0; i<line_count_2; i++)); do
        local line="${lines[$i]}"
        line_count=$((line_count + 1))
        
        # Parse the line
        IFS='|' read -r id app title <<< "$line"
        
        # Clean up whitespace
        id=$(echo "$id" | sed 's/^[ \t]*//;s/[ \t]*$//')
        title=$(echo "$title" | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        # Check if window title matches project folder
        if ./is_window_corresponds_to_project_folder.sh "$title" "$project_path" >/dev/null 2>&1; then
            window_id="$id"
            break
        fi
    done
    
    echo "$window_id"
}

# move-node-to-workspace

GODOT_ID=$(get_window_id_by_app "Godot")
CURSOR_ID=$(get_window_id_by_app_and_project "Cursor" "~/dev/godot")

echo "GODOT_ID: $GODOT_ID"
echo "CURSOR_ID: $CURSOR_ID"

# MONITOR_COUNT=$(aerospace list-monitors | wc -l)
MONITOR_COUNT=2
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