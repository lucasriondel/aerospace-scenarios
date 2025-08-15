
#!/bin/bash

# Set up logging for aerospace debugging
# Control logging behavior with environment variables or command line arguments
# LOG_DESTINATION can be: "file", "stdout", "both", or "none"
# LOG_FILE_PATH sets the log file path (default: /tmp/aerospace_debug.log)

# Parse command line arguments for logging control
LOG_DESTINATION="${LOG_DESTINATION:-file}"
LOG_FILE_PATH="${LOG_FILE_PATH:-/tmp/aerospace_debug.log}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --log-to-file)
            LOG_DESTINATION="file"
            shift
            ;;
        --log-to-stdout)
            LOG_DESTINATION="stdout"
            shift
            ;;
        --log-to-both)
            LOG_DESTINATION="both"
            shift
            ;;
        --no-log)
            LOG_DESTINATION="none"
            shift
            ;;
        --log-file)
            LOG_FILE_PATH="$2"
            LOG_DESTINATION="file"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Logging options:"
            echo "  --log-to-file          Log to file only (default)"
            echo "  --log-to-stdout        Log to stdout only"
            echo "  --log-to-both          Log to both file and stdout"
            echo "  --no-log               Disable logging"
            echo "  --log-file PATH        Set custom log file path"
            echo "  --help                 Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  LOG_DESTINATION        Set to: file, stdout, both, or none"
            echo "  LOG_FILE_PATH          Set custom log file path"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set up logging based on destination
setup_logging() {
    case "$LOG_DESTINATION" in
        "file")
            exec > "$LOG_FILE_PATH" 2>&1
            ;;
        "stdout")
            # No redirection needed, keep stdout
            ;;
        "both")
            # Use a temporary file approach for older bash compatibility
            exec > "$LOG_FILE_PATH" 2>&1
            ;;
        "none")
            exec > /dev/null 2>&1
            ;;
    esac
}

# Logging function
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

# Initialize logging
setup_logging

# Initialize log file if logging to file
if [[ "$LOG_DESTINATION" == "file" || "$LOG_DESTINATION" == "both" ]]; then
    echo "=== Aerospace Workspace Switcher Started ===" > "$LOG_FILE_PATH"
fi

log "Script started with PID: $$"
log "Logging destination: $LOG_DESTINATION"
if [[ "$LOG_DESTINATION" == "file" || "$LOG_DESTINATION" == "both" ]]; then
    log "Log file: $LOG_FILE_PATH"
fi

# Source library files
SCRIPT_DIR="$(dirname "$0")"
log "Sourcing library files from: $SCRIPT_DIR"
source "$SCRIPT_DIR/lib/get_window_id_by_app.sh"
source "$SCRIPT_DIR/lib/get_window_id_by_app_and_project.sh"
log "Library files sourced successfully"

# Configuration constants
MAIN_MONITOR_WORKSPACE=5
SECOND_MONITOR_WORKSPACE=6
log "Configuration: MAIN_MONITOR_WORKSPACE=$MAIN_MONITOR_WORKSPACE, SECOND_MONITOR_WORKSPACE=$SECOND_MONITOR_WORKSPACE"

# Get window IDs
log "Getting window IDs..."
GODOT_ID=$(aerospace_helpers_get_window_id_by_app "Godot")
log "GODOT_ID: $GODOT_ID"

CURSOR_ID=$(aerospace_helpers_get_window_id_by_app_and_project "Cursor" "~/dev/godot")
log "CURSOR_ID: $CURSOR_ID"

echo "GODOT_ID: $GODOT_ID"
echo "CURSOR_ID: $CURSOR_ID"

MONITOR_COUNT=$(aerospace list-monitors | wc -l)
log "Monitor count: $MONITOR_COUNT"

if [ "$MONITOR_COUNT" -gt 1 ]; then
        log "Multi-monitor setup detected, switching workspaces..."
        # Multi-monitor: switch between main and secondary monitor workspaces
        log "Moving Godot window ($GODOT_ID) to workspace $SECOND_MONITOR_WORKSPACE"
        aerospace move-node-to-workspace --window-id $GODOT_ID $SECOND_MONITOR_WORKSPACE
        sleep 0.1
        
        log "Moving Cursor window ($CURSOR_ID) to workspace $MAIN_MONITOR_WORKSPACE"
        aerospace move-node-to-workspace --window-id $CURSOR_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        
        log "Switching to workspace $SECOND_MONITOR_WORKSPACE"
        aerospace workspace $SECOND_MONITOR_WORKSPACE
        sleep 0.1
        
        log "Switching to workspace $MAIN_MONITOR_WORKSPACE"
        aerospace workspace $MAIN_MONITOR_WORKSPACE
    else
        log "Single monitor setup detected, managing workspaces..."
        # Single monitor: just switch between main workspaces
        log "Moving Godot window ($GODOT_ID) to workspace $MAIN_MONITOR_WORKSPACE"
        aerospace move-node-to-workspace --window-id $GODOT_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        
        log "Moving Cursor window ($CURSOR_ID) to workspace $MAIN_MONITOR_WORKSPACE"
        aerospace move-node-to-workspace --window-id $CURSOR_ID $MAIN_MONITOR_WORKSPACE
        sleep 0.1
        
        log "Setting Godot window layout to accordion"
        aerospace layout --window-id $GODOT_ID accordion
        
        log "Setting Cursor window layout to accordion"
        aerospace layout --window-id $CURSOR_ID accordion
        sleep 0.1
        
        log "Switching to workspace $MAIN_MONITOR_WORKSPACE"
        aerospace workspace $MAIN_MONITOR_WORKSPACE
    fi

log "Script completed successfully"