#!/bin/bash

# A script to restart development servers in PRE-EXISTING tmux windows.
#
# It checks for the session and each window. If a window exists, it sends
# the start command to it. If anything is missing, it reports the error
# and does nothing.

# --- 1. Configuration ---
SESSION_NAME="springhealth"
RAILS_WINDOW_NAME="rotom-srvr"
NODE_WINDOW_NAME="mp-srvr"

RAILS_PATH="/home/bonstine/dev/incubyte/springhealth/rotom"
NODE_PROJECT_PATH="/home/bonstine/dev/incubyte/springhealth/member-portal"

RAILS_COMMAND="bin/rails s"
NODE_COMMAND="yarn dev"


# --- 2. Main Logic ---

# First, check if the entire session exists. If not, we can't do anything.
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "❌ Error: tmux session '$SESSION_NAME' not found."
    echo "This script requires the session and windows to exist beforehand."
    exit 1
fi

echo "✅ Session '$SESSION_NAME' found. Checking windows..."
echo ""

# --- Process Rails Window ('rotom-srvr') ---
echo "--- Checking for Rails window: $RAILS_WINDOW_NAME ---"
# Check if the specific window exists in the session.
if tmux list-windows -t $SESSION_NAME | grep -q "$RAILS_WINDOW_NAME"; then
    echo "Window found. Sending start command..."
    # IMPORTANT: We now send the 'cd' command as part of the keys since
    # we are not creating a new window with the '-c' flag.
    # The '&&' ensures the server only starts if the 'cd' is successful.
    tmux send-keys -t "$SESSION_NAME:$RAILS_WINDOW_NAME" "cd '$RAILS_PATH' && $RAILS_COMMAND" C-m
else
    echo "⚠️  Warning: Window '$RAILS_WINDOW_NAME' not found. Cannot start Rails server."
fi

echo "" # Add a space for readability

# --- Process Node.js Window ('mp-srvr') ---
echo "--- Checking for Node.js window: $NODE_WINDOW_NAME ---"
if tmux list-windows -t $SESSION_NAME | grep -q "$NODE_WINDOW_NAME"; then
    echo "Window found. Sending start command..."
    tmux send-keys -t "$SESSION_NAME:$NODE_WINDOW_NAME" "cd '$NODE_PROJECT_PATH' && $NODE_COMMAND" C-m
else
    echo "⚠️  Warning: Window '$NODE_WINDOW_NAME' not found. Cannot start Node.js server."
fi

echo ""
echo "Script finished."
