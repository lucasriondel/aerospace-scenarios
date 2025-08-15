#!/bin/bash

# Get window ID by app name
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_get_window_id_by_app "app_name" "aerospace_window_list"
# Returns: window ID if found, empty string if not found

aerospace_helpers_get_window_id_by_app() {
    local app_name="$1"
    local aerospace_window_list="$2"
    
    if [ -z "$app_name" ] || [ -z "$aerospace_window_list" ]; then
        echo "Usage: aerospace_helpers_get_window_id_by_app <app_name> <aerospace_window_list>" >&2
        return 1
    fi
    
    # Find matching app in the provided aerospace window list
    local window_id=$(echo "$aerospace_window_list" | grep "$app_name" | head -1 | cut -d'|' -f1 | tr -d ' ')
    
    echo "$window_id"
}
