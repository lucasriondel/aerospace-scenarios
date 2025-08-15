#!/bin/bash

# Get window ID by app name and project folder match
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_get_window_id_by_app_and_project "app_name" "project_path"
# Returns: window ID if found and project matches, empty string if not found

# Source dependencies - SCRIPT_DIR should be set by the main script
if [ -z "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi
source "$SCRIPT_DIR/lib/does_window_corresponds_to_project_folder.sh"

aerospace_helpers_get_window_id_by_app_and_project() {
    local app_name="$1"
    local project_path="$2"
    
    if [ -z "$app_name" ] || [ -z "$project_path" ]; then
        echo "Usage: aerospace_helpers_get_window_id_by_app_and_project <app_name> <project_path>" >&2
        return 1
    fi
    
    # Get aerospace window list and filter by app
    local filtered_windows=$(aerospace list-windows --all | grep "$app_name")
    
    # Check each window for project match - avoid subshell by using array
    local window_id=""
    local line_count=0
    
    # Process each line directly to avoid array compatibility issues
    while IFS='|' read -r id app title; do
        line_count=$((line_count + 1))
        
        # Clean up whitespace
        id=$(echo "$id" | sed 's/^[ \t]*//;s/[ \t]*$//')
        title=$(echo "$title" | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        # Check if window title matches project folder
        if aerospace_helpers_does_window_corresponds_to_project_folder "$title" "$project_path"; then
            window_id="$id"
            break
        fi
    done <<< "$filtered_windows"
    
    echo "$window_id"
}
