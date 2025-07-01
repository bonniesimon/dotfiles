#!/bin/bash

# A script to safely stop the development servers for the SpringHealth project.
# The project paths are hardcoded in this script for ease of use.

# You can change these paths if your project moves.
RAILS_PATH="/home/bonstine/dev/incubyte/springhealth/rotom"
NODE_PROJECT_PATH="/home/bonstine/dev/incubyte/springhealth/member-portal/packages/cherrim"

# Verify that the hardcoded paths exist before proceeding
if [ ! -d "$RAILS_PATH" ]; then
    echo "Error: Rails directory not found at the hardcoded path: '$RAILS_PATH'"
    exit 1
fi
if [ ! -d "$NODE_PROJECT_PATH" ]; then
    echo "Error: Node.js project directory not found at the hardcoded path: '$NODE_PROJECT_PATH'"
    exit 1
fi


# --- 2. Stop the Rails Server (using PID file) ---
echo "--- Stopping Rails Server for project: rotom ---"
RAILS_PID_FILE="$RAILS_PATH/tmp/pids/server.pid"

if [ -f "$RAILS_PID_FILE" ]; then
    RAILS_PID=$(cat "$RAILS_PID_FILE")
    # Check if a process with this PID is actually running
    if ps -p "$RAILS_PID" > /dev/null; then
        echo "Found running server with PID $RAILS_PID from $RAILS_PID_FILE. Sending stop signal..."
        kill "$RAILS_PID"
        # Optional: wait a moment to see if it shuts down
        sleep 1
        if ! ps -p "$RAILS_PID" > /dev/null; then
             echo "Server stopped successfully."
        else
             echo "Warning: Server may not have stopped. Consider using 'kill -9 $RAILS_PID'."
        fi
    else
        echo "Found stale PID file, but no process with PID $RAILS_PID is running. Removing file."
        rm "$RAILS_PID_FILE"
    fi
else
    echo "No server.pid file found. The Rails server is likely not running."
fi

echo "" # Add a space for readability

# --- 3. Stop the Node.js Server (Safe Method) ---
echo "--- Stopping Node.js Server for project: member-portal ---"

# Get the absolute path of the project directory to ensure a reliable match
ABS_NODE_PATH=$(cd "$NODE_PROJECT_PATH" && pwd)
FOUND_PID=0

# Find processes matching your "node server.js" command
for pid in $(pgrep -f "[n]ode --max-old-space-size=8192 server.js"); do
    # Get the process's current working directory (CWD)
    PROCESS_CWD=$(readlink -f /proc/$pid/cwd)

    # If the process's CWD matches the project path, we've found our server
    if [ "$PROCESS_CWD" == "$ABS_NODE_PATH" ]; then
        echo "Found running Node.js server with PID $pid in the correct directory."
        echo "Sending stop signal..."
        kill "$pid"
        FOUND_PID=$pid
    fi
done

if [ "$FOUND_PID" -eq 0 ]; then
    echo "No running 'node server.js' process was found for this directory."
fi
