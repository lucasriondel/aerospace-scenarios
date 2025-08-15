#!/bin/bash

# Utility helpers for scenario system

# Check if logging functions are available, if not provide fallbacks
if ! declare -F log >/dev/null 2>&1; then
    # Fallback logging functions if not sourced from main script
    log() { echo "$1"; }
    log_verbose() { :; }  # No-op for verbose logging
    log_debug() { :; }    # No-op for debug logging
    log_error() { echo "ERROR: $1" >&2; }
    log_warning() { echo "WARNING: $1" >&2; }
    log_success() { echo "SUCCESS: $1"; }
fi

# Use the logging functions from the main script
scenarios_log() {
    log "$1"
}

scenarios_fail() {
    log_error "$1"
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


