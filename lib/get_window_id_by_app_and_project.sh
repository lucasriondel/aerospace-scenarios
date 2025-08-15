#!/bin/bash

# Get window ID by app name and project folder match
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_get_window_id_by_app_and_project "app_name" "project_path"
# Returns: window ID if found and project matches, empty string if not found

# Source dependencies
if [ -z "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi
source "$SCRIPT_DIR/lib/match.sh"

aerospace_helpers_get_window_id_by_app_and_project() {
    local app_name="$1"
    local project_path="$2"
    
    if [ -z "$app_name" ] || [ -z "$project_path" ]; then
        echo "Usage: aerospace_helpers_get_window_id_by_app_and_project <app_name> <project_path>" >&2
        return 1
    fi
    
    # Expand tilde to home directory
    project_path=$(eval echo "$project_path")
    
    # Check if project path exists
    if [ ! -d "$project_path" ]; then
        echo "Error: Project path '$project_path' does not exist" >&2
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
        
        # Check if any project folder name appears in the window title
        local match_found=false
        local temp_file=$(mktemp)
        find "$project_path" -maxdepth 1 -type d -exec basename {} \; | tail -n +2 > "$temp_file"
        
        while IFS= read -r folder; do
            if [[ -n "$folder" ]]; then
                if aerospace_helpers_match "$folder" "$title"; then
                    match_found=true
                    break
                fi
            fi
        done < "$temp_file"
        
        rm "$temp_file"
        
        if [ "$match_found" = true ]; then
            window_id="$id"
            break
        fi
    done <<< "$filtered_windows"
    
    echo "$window_id"
}
