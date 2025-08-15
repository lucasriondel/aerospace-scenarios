#!/bin/bash

# Resolve workspaces and windows into usable IDs

SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR_LOCAL/util.sh"
source "$SCRIPT_DIR_LOCAL/parse.sh"

# Source existing helper libraries
if [ -z "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
source "$SCRIPT_DIR/lib/get_window_id_by_app.sh"
source "$SCRIPT_DIR/lib/get_window_id_by_app_and_project.sh"
source "$SCRIPT_DIR/lib/get_window_id_by_app_and_title_match.sh"

scenarios_get_aerospace_window_list() {
    # Best effort: format as id|app|title
    if aerospace list-windows --help >/dev/null 2>&1; then
        local fmt="%{window-id}|%{app-name}|%{window-title}"
        aerospace list-windows --all --format "$fmt" 2>/dev/null && return 0
    fi
    scenarios_fail "Unable to obtain window list from aerospace (list-windows not available)"
    return 1
}

scenarios_resolve_workspace_map() {
    local yaml_path="$1"
    scenarios_parse_workspaces "$yaml_path"
}

scenarios_resolve_window_map() {
    local yaml_path="$1"
    local window_list="$2"
    local results=""

    local defs; defs=$(scenarios_parse_windows "$yaml_path")
    if [ -z "$defs" ]; then
        echo ""
        return 0
    fi

    while IFS='|' read -r w_name w_type w_app w_project w_title; do
        local id=""
        case "$w_type" in
            app)
                id=$(aerospace_helpers_get_window_id_by_app "$w_app" "$window_list")
                ;;
            app_and_project)
                id=$(aerospace_helpers_get_window_id_by_app_and_project "$w_app" "$w_project" "$window_list")
                ;;
            app_and_title)
                id=$(aerospace_helpers_get_window_id_by_app_and_title_match "$w_app" "$w_title" "$window_list")
                ;;
        esac
        results+="$w_name|$id\n"
    done <<< "$defs"

    # Print mapping lines
    echo -e "$results" | sed '/^$/d'
}


