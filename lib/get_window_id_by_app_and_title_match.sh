#!/bin/bash

# Get window ID by app name and title string match
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_get_window_id_by_app_and_title_match "app_name" "title_string" "aerospace_window_list"
# Returns: window ID if found and title string matches, empty string if not found

# Source dependencies
if [ -z "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(dirname "$0")/.."
fi
source "$SCRIPT_DIR/lib/match.sh"

aerospace_helpers_get_window_id_by_app_and_title_match() {
    local app_name="$1"
    local title_string="$2"
    local aerospace_window_list="$3"
    
    if [ -z "$app_name" ] || [ -z "$title_string" ] || [ -z "$aerospace_window_list" ]; then
        echo "Usage: aerospace_helpers_get_window_id_by_app_and_title_match <app_name> <title_string> <aerospace_window_list>" >&2
        return 1
    fi
    
    # Filter aerospace window list by app
    local filtered_windows=$(echo "$aerospace_window_list" | grep "$app_name")
    
    # Check each window for title string match
    local window_id=""
    local line_count=0
    
    # Process each line directly to avoid array compatibility issues
    while IFS='|' read -r id app title; do
        line_count=$((line_count + 1))
        
        # Clean up whitespace
        id=$(echo "$id" | sed 's/^[ \t]*//;s/[ \t]*$//')
        title=$(echo "$title" | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        # Check if title string appears in the window title using the match function
        if aerospace_helpers_match "$title_string" "$title"; then
            window_id="$id"
            break
        fi
    done <<< "$filtered_windows"
    
    echo "$window_id"
}
