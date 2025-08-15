#!/bin/bash

# Execute a scenario: monitor condition + commands

SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR_LOCAL/util.sh"
source "$SCRIPT_DIR_LOCAL/parse.sh"
source "$SCRIPT_DIR_LOCAL/resolve.sh"

scenarios_monitor_count() {
    aerospace list-monitors 2>/dev/null | wc -l | tr -d ' '
}

scenarios_monitor_condition_holds() {
    local yaml_path="$1"
    local scenario_name="$2"
    local cond; cond=$(scenarios_parse_monitor_condition "$yaml_path" "$scenario_name")
    local op; op="${cond%%|*}"; local val; val="${cond#*|}"
    local count; count=$(scenarios_monitor_count)
    
    log_debug "Condition check - op: $op, val: $val, count: $count"

    case "$op" in
        eq) [ "$count" -eq "$val" ] ;;
        gt) [ "$count" -gt "$val" ] ;;
        gte) [ "$count" -ge "$val" ] ;;
        lt) [ "$count" -lt "$val" ] ;;
        lte) [ "$count" -le "$val" ] ;;
    esac
    
    local result=$?
    log_debug "Condition result: $result"
    return $result
}

scenarios_find_matching_scenario() {
    local yaml_path="$1"
    local scenario_names; scenario_names=$(scenarios_parse_scenario_names "$yaml_path")
    local result=""
    
    log_debug "Found scenarios: $scenario_names"
    
    # Convert to array to avoid file reading issues
    local scenarios=()
    while IFS= read -r name; do
        [ -n "$name" ] && scenarios+=("$name")
    done <<< "$scenario_names"
    
    log_debug "Array has ${#scenarios[@]} elements: ${scenarios[*]}"
    
    # Process each scenario
    for scenario_name in "${scenarios[@]}"; do
        log_debug "Checking scenario: $scenario_name"
        
        local cond; cond=$(scenarios_parse_monitor_condition "$yaml_path" "$scenario_name")
        local op; op="${cond%%|*}"; local val; val="${cond#*|}"
        local count; count=$(scenarios_monitor_count)
        
        log_debug "Condition check - op: $op, val: $val, count: $count"
        
        local condition_holds=false
        case "$op" in
            eq) [ "$count" -eq "$val" ] && condition_holds=true ;;
            gt) [ "$count" -gt "$val" ] && condition_holds=true ;;
            gte) [ "$count" -ge "$val" ] && condition_holds=true ;;
            lt) [ "$count" -lt "$val" ] && condition_holds=true ;;
            lte) [ "$count" -le "$val" ] && condition_holds=true ;;
        esac
        
        if [ "$condition_holds" = true ]; then
            log_debug "Match found: $scenario_name"
            result="$scenario_name"
            break
        else
            log_debug "No match for: $scenario_name"
        fi
    done
    
    log_debug "Final result: '$result'"
    echo "$result"
}

scenarios_build_placeholder_maps() {
    local yaml_path="$1"

    local ws_lines; ws_lines=$(scenarios_resolve_workspace_map "$yaml_path")
    local window_list; window_list=$(scenarios_get_aerospace_window_list)
    local win_lines; win_lines=$(scenarios_resolve_window_map "$yaml_path" "$window_list")

    echo "WORKSPACES<<EOF"
    echo "$ws_lines"
    echo "EOF"
    echo "WINDOWS<<EOF"
    echo "$win_lines"
    echo "EOF"
}

scenarios_replace_placeholders() {
    local command_line="$1"
    shift
    local ws_map="$1"
    local win_map="$2"

    local out="$command_line"

    # Replace workspace placeholders
    while IFS='|' read -r ws_name ws_id; do
        [ -z "$ws_name" ] && continue
        out=$(echo "$out" | sed "s/{workspace:${ws_name}}/${ws_id}/g")
    done <<< "$ws_map"

    # Replace window placeholders
    while IFS='|' read -r w_name w_id; do
        [ -z "$w_name" ] && continue
        out=$(echo "$out" | sed "s/{window:${w_name}}/${w_id}/g")
    done <<< "$win_map"

    echo "$out"
}

scenarios_execute_commands() {
    local yaml_path="$1"
    local scenario_name="$2"

    local blocks; blocks=$(scenarios_build_placeholder_maps "$yaml_path")
    local ws_map; ws_map=$(echo "$blocks" | awk '/^WORKSPACES<<EOF/{flag=1;next}/^EOF$/{flag=0}flag')
    local win_map; win_map=$(echo "$blocks" | awk '/^WINDOWS<<EOF/{flag=1;next}/^EOF$/{flag=0}flag')

    while IFS= read -r cmd; do
        [ -z "$cmd" ] && continue
        local final_cmd; final_cmd=$(scenarios_replace_placeholders "$cmd" "$ws_map" "$win_map")
        log "Running: $final_cmd"
        eval "$final_cmd"
        sleep 0.1
    done < <(scenarios_parse_commands "$yaml_path" "$scenario_name")
}


