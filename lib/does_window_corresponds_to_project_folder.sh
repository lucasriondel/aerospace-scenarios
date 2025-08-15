#!/bin/bash

# Function to check if a window title corresponds to a project folder
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_does_window_corresponds_to_project_folder "window_title" "project_path"
# Returns: true (0) if match found, false (1) if no match

aerospace_helpers_does_window_corresponds_to_project_folder() {
    local window_title="$1"
    local project_path="$2"
    
    # Check if correct number of arguments provided
    if [ $# -ne 2 ]; then
        echo "Usage: aerospace_helpers_does_window_corresponds_to_project_folder <window_title> <project_path>" >&2
        echo "Example: aerospace_helpers_does_window_corresponds_to_project_folder 'mining.Tests.csproj — mining (Workspace)' '~/dev/godot'" >&2
        return 1
    fi
    
    # Expand tilde to home directory
    project_path=$(eval echo "$project_path")
    
    # Check if project path exists
    if [ ! -d "$project_path" ]; then
        echo "Error: Project path '$project_path' does not exist" >&2
        return 1
    fi
    
    # Get list of folders in project path
    local project_folders=$(find "$project_path" -maxdepth 1 -type d -exec basename {} \; | tail -n +2)
    
    # Check if any project folder name appears in the window title
    local match_found=false
    while IFS= read -r folder; do
        if [[ -n "$folder" && "$window_title" == *"$folder"* ]]; then
            match_found=true
            break
        fi
    done <<< "$project_folders"
    
    # Return result
    if [ "$match_found" = true ]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# If script is run directly, execute the function with command line arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    aerospace_helpers_does_window_corresponds_to_project_folder "$@"
fi