#!/bin/bash

# Path to the Custom.terminal file
TERMINAL_PROFILE_PATH=$1

# Open the Terminal profile to import it and wait a moment to ensure it is imported
open "$TERMINAL_PROFILE_PATH"
sleep 1

# AppleScript to set the imported profile as the default
osascript <<EOF
tell application "Terminal"
    set profileName to "Custom"
    set default settings to settings set profileName
end tell
EOF


