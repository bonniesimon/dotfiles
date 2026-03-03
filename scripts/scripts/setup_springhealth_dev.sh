#!/bin/bash

# Development environment setup script
# Opens cursor, zed, vscode, and chromium for development

PROJECT_DIR="/home/bonstine/dev/incubyte/springhealth/member-portal"

echo "Setting up development environment..."

# Open Cursor in project directory
if ! pgrep -f "cursor.appimage.*${PROJECT_DIR}" > /dev/null; then
    echo "Opening Cursor..."
    nohup ~/Applications/cursor.appimage "$PROJECT_DIR" > /dev/null 2>&1 &
else
    echo "Cursor already open in project directory"
fi

# Open Zed in project directory
if ! pgrep -f "zed.*${PROJECT_DIR}" > /dev/null; then
    echo "Opening Zed..."
    zed "$PROJECT_DIR" &
else
    echo "Zed already open in project directory"
fi

# Open VSCode (no specific folder)
if ! pgrep -x "code" > /dev/null; then
    echo "Opening VSCode..."
    code &
else
    echo "VSCode already running"
fi

# Open Chromium if not already running
if ! pgrep -x "chromium" > /dev/null && ! pgrep -x "chromium-browser" > /dev/null; then
    echo "Opening Chromium..."
    chromium &
else
    echo "Chromium already running"
fi

echo "Development environment setup complete!"
