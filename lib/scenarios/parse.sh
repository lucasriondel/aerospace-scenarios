#!/bin/bash

# YAML parsing utilities (requires yq)

SCRIPT_DIR_LOCAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR_LOCAL/util.sh"

scenarios_require_cmd yq || exit 1

scenarios_parse_name() {
    local yaml_path="$1"
    yq -r '.name' "$yaml_path" 2>/dev/null || echo ""
}

scenarios_parse_workspaces() {
    local yaml_path="$1"
    yq -r '.workspaces[]? | "\(.name)|\(.id)"' "$yaml_path" 2>/dev/null || echo ""
}

scenarios_parse_windows() {
    local yaml_path="$1"
    # Output: name|type|app|project|title
    yq -r '.windows[]? | .name as $n | .find.type as $t | (.find.app // "") as $a | (.find.project // "") as $p | (.find.title // "") as $ti | "\($n)|\($t)|\($a)|\($p)|\($ti)"' "$yaml_path" 2>/dev/null || echo ""
}

scenarios_parse_scenario_names() {
    local yaml_path="$1"
    yq -r '.scenarios | keys[]?' "$yaml_path" 2>/dev/null || echo ""
}

scenarios_parse_monitor_condition() {
    local yaml_path="$1"
    local scenario_name="$2"
    # Output: op|value
    local op; op=$(yq -r ".scenarios.$scenario_name.when.monitors.op" "$yaml_path" 2>/dev/null || echo "gt")
    local value; value=$(yq -r ".scenarios.$scenario_name.when.monitors.value" "$yaml_path" 2>/dev/null || echo "1")
    echo "$op|$value"
}

scenarios_parse_commands() {
    local yaml_path="$1"
    local scenario_name="$2"
    log_debug "parse_commands called with yaml_path: '$yaml_path', scenario_name: '$scenario_name'" >&2
    local result; result=$(yq -r ".scenarios.$scenario_name.commands[]" "$yaml_path" 2>/dev/null || echo "")
    log_debug "parse_commands result: '$result'" >&2
    echo "$result"
}


