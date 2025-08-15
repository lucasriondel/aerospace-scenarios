#!/bin/bash

# Utility helpers for scenario system

scenarios_log() {
    local message="$1"
    if declare -F log >/dev/null 2>&1; then
        log "$message"
    else
        echo "$message"
    fi
}

scenarios_fail() {
    local message="$1"
    scenarios_log "ERROR: $message"
    return 1
}

scenarios_require_cmd() {
    local cmd_name="$1"
    if ! command -v "$cmd_name" >/dev/null 2>&1; then
        scenarios_fail "Required command not found: $cmd_name"
        return 1
    fi
}

# Resolve script root (project) and library paths
if [ -z "$AEROSPACE_SCRIPT_ROOT" ]; then
    AEROSPACE_SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
fi

SCENARIOS_LIB_DIR="$AEROSPACE_SCRIPT_ROOT/lib/scenarios"


