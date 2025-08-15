#!/bin/bash

# Script to check if a window title corresponds to a project folder
# Usage: ./is_window_title_correspond_to_project_folder.sh "window_title" "project_path"
# Returns: true (0) if match found, false (1) if no match

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <window_title> <project_path>"
    echo "Example: $0 'mining.Tests.csproj — mining (Workspace)' '~/dev/godot'"
    exit 1
fi

WINDOW_TITLE="$1"
PROJECT_PATH="$2"

# Expand tilde to home directory
PROJECT_PATH=$(eval echo "$PROJECT_PATH")

# Check if project path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: Project path '$PROJECT_PATH' does not exist" >&2
    exit 1
fi

# Get list of folders in project path
PROJECT_FOLDERS=$(find "$PROJECT_PATH" -maxdepth 1 -type d -exec basename {} \; | tail -n +2)

# Debug output (comment out if not needed)
echo "Checking window title: '$WINDOW_TITLE'" >&2
echo "Project path: '$PROJECT_PATH'" >&2
echo "Available project folders:" >&2
echo "$PROJECT_FOLDERS" | sed 's/^/  - /' >&2

# Check if any project folder name appears in the window title
MATCH_FOUND=false
while IFS= read -r folder; do
    if [[ -n "$folder" && "$WINDOW_TITLE" == *"$folder"* ]]; then
        echo "Match found: '$folder' in window title" >&2
        MATCH_FOUND=true
        break
    fi
done <<< "$PROJECT_FOLDERS"

# Return result
if [ "$MATCH_FOUND" = true ]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi