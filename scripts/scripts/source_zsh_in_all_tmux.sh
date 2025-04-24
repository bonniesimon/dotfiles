#!/bin/bash

# Check if tmux is running
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed or not available in PATH."
    exit 1
fi

# Get the list of pane IDs in the current tmux session
panes=$(tmux list-panes -s -F "#{pane_id}" 2>/dev/null)

# Check if any panes are found
if [ -z "$panes" ]; then
    echo "No panes found in the current tmux session."
    exit 1
fi

# Iterate through each pane and send the command
for pane in $panes; do
    tmux send-keys -t "$pane" "source ~/.zshrc" Enter
done

echo "Command 'source ~/.zshrc' sent to all panes."
