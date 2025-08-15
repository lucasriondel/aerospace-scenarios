#!/bin/bash

# Aerospace Logging Library
# Provides consistent logging across all aerospace scripts

# Default logging configuration
LOG_DESTINATION="${LOG_DESTINATION:-file}"
LOG_FILE_PATH="${LOG_FILE_PATH:-/tmp/aerospace_scenarios.log}"
LOG_VERBOSE="${LOG_VERBOSE:-false}"

# Parse command line arguments for logging control
parse_logging_args() {
    local args=("$@")
    local remaining=()
    local log_dest="file"
    local log_file="/tmp/aerospace_scenarios.log"
    local log_verbose="false"
    local skip_next=false
    
    for i in "${!args[@]}"; do
        local arg="${args[$i]}"
        
        if [ "$skip_next" = true ]; then
            skip_next=false
            continue
        fi
        
        case "$arg" in
            --log-to-file)
                log_dest="file"
                ;;
            --log-to-stdout)
                log_dest="stdout"
                ;;
            --log-to-both)
                log_dest="both"
                ;;
            --no-log)
                log_dest="none"
                ;;
            --log-file)
                if [ $((i+1)) -lt ${#args[@]} ]; then
                    log_file="${args[$((i+1))]}"
                    skip_next=true
                fi
                log_dest="file"
                ;;
            --verbose)
                log_verbose="true"
                ;;
            --help)
                # Help is handled separately in the main script
                ;;
            *)
                # Keep this argument
                remaining+=("$arg")
                ;;
        esac
    done
    
    # Set global variables
    LOG_DESTINATION="$log_dest"
    LOG_FILE_PATH="$log_file"
    LOG_VERBOSE="$log_verbose"
    
    # Store remaining arguments in global variable
    REMAINING_ARGS=("${remaining[@]}")
}

# Set up logging based on destination
setup_logging() {
    case "$LOG_DESTINATION" in
        "file")
            exec > "$LOG_FILE_PATH" 2>&1
            ;;
        "stdout")
            # No redirection needed, keep stdout
            # Ensure we're not redirecting to file
            ;;
        "both")
            # For both, we'll use a different approach to avoid exec conflicts
            # We'll log to file but also echo to stdout
            ;;
        "none")
            exec > /dev/null 2>&1
            ;;
    esac
}

# Main logging function
log() {
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    local message="$timestamp $1"
    
    case "$LOG_DESTINATION" in
        "file")
            echo "$message" >> "$LOG_FILE_PATH"
            ;;
        "stdout")
            echo "$message"
            ;;
        "both")
            echo "$message" | tee -a "$LOG_FILE_PATH"
            ;;
        "none")
            # Do nothing
            ;;
    esac
}

# Verbose logging function - only logs when verbose mode is enabled
log_verbose() {
    if [ "$LOG_VERBOSE" = "true" ]; then
        log "VERBOSE: $1"
    fi
}

# Debug logging function - only logs when verbose mode is enabled
log_debug() {
    if [ "$LOG_VERBOSE" = "true" ]; then
        log "DEBUG: $1"
    fi
}

# Error logging function - always logs
log_error() {
    log "ERROR: $1"
}

# Warning logging function - always logs
log_warning() {
    log "WARNING: $1"
}

# Success logging function - always logs
log_success() {
    log "SUCCESS: $1"
}

# Initialize logging system
init_logging() {
    # Set default values if not already set
    LOG_DESTINATION="${LOG_DESTINATION:-file}"
    LOG_FILE_PATH="${LOG_FILE_PATH:-/tmp/aerospace_scenarios.log}"
    LOG_VERBOSE="${LOG_VERBOSE:-false}"
    
    # Log startup information
    log "=== Aerospace Scenarios Started ==="
    log "Script started with PID: $$"
    log "Logging destination: $LOG_DESTINATION"
    if [ "$LOG_VERBOSE" = "true" ]; then
        log_verbose "Verbose logging: true"
    fi
    log "Log file: $LOG_FILE_PATH"
}
