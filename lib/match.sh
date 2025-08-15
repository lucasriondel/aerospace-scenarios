#!/bin/bash

# Simple string matching utility function
# Namespace: aerospace_helpers
# Usage: aerospace_helpers_match "search_string" "target_string"
# Returns: 0 (true) if search_string is found in target_string, 1 (false) if not found

aerospace_helpers_match() {
    local search_string="$1"
    local target_string="$2"
    
    if [ -z "$search_string" ] || [ -z "$target_string" ]; then
        echo "Usage: aerospace_helpers_match <search_string> <target_string>" >&2
        return 1
    fi
    
    # Check if search_string appears in target_string
    if [[ "$target_string" == *"$search_string"* ]]; then
        return 0  # true - match found
    else
        return 1  # false - no match
    fi
}
