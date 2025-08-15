#!/bin/bash

SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR_LOCAL/util.sh"
source "$SCRIPT_DIR_LOCAL/validator.sh"
source "$SCRIPT_DIR_LOCAL/execute.sh"

usage() {
    echo "Usage: $0 <scenario_yaml_path>"
}

main() {
    local yaml_path="$1"
    if [ -z "$yaml_path" ]; then
        usage
        exit 1
    fi
    if [ ! -f "$yaml_path" ]; then
        scenarios_fail "Scenario file not found: $yaml_path" || exit 1
    fi

    scenarios_validate_required_tools || exit 1
    scenarios_validate_schema "$yaml_path" || exit 1

    local matching_scenario; matching_scenario=$(scenarios_find_matching_scenario "$yaml_path")
    if [ -n "$matching_scenario" ]; then
        scenarios_log "Monitor condition holds for scenario '$matching_scenario'. Executing scenario."
        scenarios_execute_commands "$yaml_path" "$matching_scenario"
    else
        scenarios_log "No scenario conditions match. Skipping execution."
    fi
}

main "$@"


