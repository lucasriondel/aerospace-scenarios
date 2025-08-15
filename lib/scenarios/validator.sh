#!/bin/bash

# Scenario config validator

SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR_LOCAL/util.sh"
source "$SCRIPT_DIR_LOCAL/parse.sh"

scenarios_validate_required_tools() {
    scenarios_require_cmd yq || return 1
    scenarios_require_cmd aerospace || return 1
}

scenarios_validate_schema() {
    local yaml_path="$1"

    local name; name=$(scenarios_parse_name "$yaml_path")
    if [ -z "$name" ]; then
        scenarios_fail "Missing required field: name" || return 1
    fi

    # Workspaces: must exist and have unique names and numeric ids
    local ws_lines; ws_lines=$(scenarios_parse_workspaces "$yaml_path")
    if [ -z "$ws_lines" ]; then
        scenarios_fail "At least one workspace is required" || return 1
    fi

    local seen_ws_names="|"
    while IFS='|' read -r ws_name ws_id; do
        if [ -z "$ws_name" ] || [ -z "$ws_id" ]; then
            scenarios_fail "Workspace entries must have name and id" || return 1
        fi
        if ! [[ "$ws_id" =~ ^[0-9]+$ ]]; then
            scenarios_fail "Workspace id for '$ws_name' must be an integer" || return 1
        fi
        if [[ "$seen_ws_names" == *"|$ws_name|"* ]]; then
            scenarios_fail "Duplicate workspace name: $ws_name" || return 1
        fi
        seen_ws_names+="$ws_name|"
    done <<< "$ws_lines"

    # Windows: optional but validate if present
    local win_lines; win_lines=$(scenarios_parse_windows "$yaml_path")
    local seen_win_names="|"
    if [ -n "$win_lines" ]; then
        while IFS='|' read -r w_name w_type w_app w_project w_title; do
            if [ -z "$w_name" ] || [ -z "$w_type" ]; then
                scenarios_fail "Each window must have name and find.type" || return 1
            fi
            if [[ "$seen_win_names" == *"|$w_name|"* ]]; then
                scenarios_fail "Duplicate window name: $w_name" || return 1
            fi
            seen_win_names+="$w_name|"
            case "$w_type" in
                app)
                    if [ -z "$w_app" ]; then scenarios_fail "Window '$w_name' (type=app) requires find.app" || return 1; fi
                    ;;
                app_and_project)
                    if [ -z "$w_app" ] || [ -z "$w_project" ]; then scenarios_fail "Window '$w_name' (type=app_and_project) requires find.app and find.project" || return 1; fi
                    ;;
                app_and_title)
                    if [ -z "$w_app" ] || [ -z "$w_title" ]; then scenarios_fail "Window '$w_name' (type=app_and_title) requires find.app and find.title" || return 1; fi
                    ;;
                *)
                    scenarios_fail "Unsupported window find.type '$w_type' for window '$w_name'" || return 1
                    ;;
            esac
        done <<< "$win_lines"
    fi

    # Commands: at least one
    local scenario_names; scenario_names=$(scenarios_parse_scenario_names "$yaml_path")
    if [ -z "$scenario_names" ]; then
        scenarios_fail "scenarios section must contain at least one scenario" || return 1
    fi
    
    # Validate each scenario
    while IFS= read -r scenario_name; do
        [ -z "$scenario_name" ] && continue
        
        local cmds; cmds=$(scenarios_parse_commands "$yaml_path" "$scenario_name")
        if [ -z "$cmds" ]; then
            scenarios_fail "scenario '$scenario_name' must contain at least one command" || return 1
        fi
        
        # Placeholders reference existing names
        local referenced_ws=()
        local referenced_win=()
        # Extract placeholders
        local placeholder_lines; placeholder_lines=$(echo "$cmds" | grep -oE '\{(workspace|window):[^}]+\}' | tr -d '{}' || true)
        if [ -n "$placeholder_lines" ]; then
            while IFS= read -r token; do
                local kind; kind="${token%%:*}"
                local ref; ref="${token#*:}"
                case "$kind" in
                    workspace)
                        referenced_ws+=("$ref")
                        ;;
                    window)
                        referenced_win+=("$ref")
                        ;;
                esac
            done <<< "$placeholder_lines"
        fi

        # Verify referenced workspaces exist
        if [ ${#referenced_ws[@]} -gt 0 ]; then
            local missing_ws=""
            # Check each referenced workspace
            for ref_ws in "${referenced_ws[@]}"; do
                local found=false
                while IFS='|' read -r ws_name ws_id; do
                    if [ "$ws_name" = "$ref_ws" ]; then
                        found=true
                        break
                    fi
                done <<< "$ws_lines"
                if [ "$found" = false ]; then
                    missing_ws+="$ref_ws "
                fi
            done
            
            if [ -n "$missing_ws" ]; then
                scenarios_fail "Unknown workspace(s) referenced in scenario '$scenario_name': $missing_ws" || return 1
            fi
        fi

        # Verify referenced windows exist
        if [ ${#referenced_win[@]} -gt 0 ]; then
            if [ -z "$win_lines" ]; then
                scenarios_fail "Scenario '$scenario_name' references windows but 'windows' section is empty" || return 1
            fi
            
            local missing_win=""
            # Check each referenced window
            for ref_win in "${referenced_win[@]}"; do
                local found=false
                while IFS='|' read -r w_name _rest; do
                    if [ "$w_name" = "$ref_win" ]; then
                        found=true
                        break
                    fi
                done <<< "$win_lines"
                if [ "$found" = false ]; then
                    missing_win+="$ref_win "
                fi
            done
            
            if [ -n "$missing_win" ]; then
                scenarios_fail "Unknown window(s) referenced in scenario '$scenario_name': $missing_win" || return 1
            fi
        fi
        
        # Monitor condition: op is supported and value is int
        local cond; cond=$(scenarios_parse_monitor_condition "$yaml_path" "$scenario_name")
        local op; op="${cond%%|*}"; local val; val="${cond#*|}"
        case "$op" in
            eq|gt|gte|lt|lte) ;;
            *) scenarios_fail "Unsupported monitor condition op in scenario '$scenario_name': $op (use one of eq, gt, gte, lt, lte)" || return 1;;
        esac
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            scenarios_fail "Monitor condition value in scenario '$scenario_name' must be an integer" || return 1
        fi
    done <<< "$scenario_names"

    return 0
}


