#!/usr/bin/env bash

# Set script name
script_name=$(basename "$0")
script_name="${script_name%.*}"

# Set log directory
LOG_DIR="$HOME/Desktop/${script_name}-logs"
TAP_LOG_DIR="${LOG_DIR}/taps"
FORMULA_LOG_DIR="${LOG_DIR}/formulas"
CASK_LOG_DIR="${LOG_DIR}/casks"

# Create log directories
mkdir -p "${TAP_LOG_DIR}" "${FORMULA_LOG_DIR}" "${CASK_LOG_DIR}"

# Temporary log file
TMP="${script_name}.tmp"

# Clear temporary log file
echo "" > "$TMP"

# Homebrew Installation and Update
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    echo -e "\n-----------------------------------------------------------------------------------------------------\n" >> "$TMP"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$TMP" 2>&1 &
    wait $!
else
    current_version=$(brew --version | awk 'NR==1 {print $2}')
    echo -e "\n-----------------------------------------------------------------------------------------------------\n" >> "$TMP"
    echo "Found Homebrew version: ${current_version}. Attempting to Update..."
    brew update >> "$TMP" 2>&1 &
    wait $!
fi

# Fetching Taps
echo "Fetching taps..."
brew tap homebrew/services > "${TAP_LOG_DIR}/brew-services.log" 2>&1
brew tap homebrew/cask > "${TAP_LOG_DIR}/brew-cask.log" 2>&1
brew tap elastic/tap > "${TAP_LOG_DIR}/elastic-tap.log" 2>&1
brew tap mongodb/tap > "${TAP_LOG_DIR}/mongodb-tap.log" 2>&1

# Installing Formulas
echo "Installing formulas..."
# Languages
brew install python3 > "${FORMULA_LOG_DIR}/python3.log" 2>&1
# Package Managers
brew install gradle > "${FORMULA_LOG_DIR}/gradle.log" 2>&1
brew install node > "${FORMULA_LOG_DIR}/node.log" 2>&1
# Editors
brew install gedit > "${FORMULA_LOG_DIR}/gedit.log" 2>&1
brew install nano > "${FORMULA_LOG_DIR}/nano.log" 2>&1
# Databases
brew install elasticsearch-full > "${FORMULA_LOG_DIR}/elasticsearch-full.log" 2>&1
brew install kibana-full > "${FORMULA_LOG_DIR}/kibana-full.log" 2>&1
brew install mongosh > "${FORMULA_LOG_DIR}/mongosh.log" 2>&1
brew install mongodb-community > "${FORMULA_LOG_DIR}/mongodb-community.log" 2>&1
# Message Queues
brew install zookeeper > "${FORMULA_LOG_DIR}/zookeeper.log" 2>&1
brew install kafka > "${FORMULA_LOG_DIR}/kafka.log" 2>&1

# Installing Casks
echo "Installing casks..."
# IDEs and Editors
brew install --cask sublime-text > "${CASK_LOG_DIR}/sublime-text.log" 2>&1
brew install --cask intellij-idea > "${CASK_LOG_DIR}/intellij-idea.log" 2>&1
brew install --cask intellij-idea-ce > "${CASK_LOG_DIR}/intellij-idea-ce.log" 2>&1
brew install --cask visual-studio-code > "${CASK_LOG_DIR}/visual-studio-code.log" 2>&1
# Dev UI tools
brew install --cask docker > "${CASK_LOG_DIR}/docker.log" 2>&1
brew install --cask virtualbox > "${CASK_LOG_DIR}/virtualbox.log" 2>&1
brew install --cask mongodb-compass > "${CASK_LOG_DIR}/mongodb-compass.log" 2>&1
# Personal
brew install --cask vlc > "${CASK_LOG_DIR}/vlc.log" 2>&1
brew install -cask spotify > "${CASK_LOG_DIR}/spotify.log" 2>&1
brew install --cask whatsapp > "${CASK_LOG_DIR}/whatsapp.log" 2>&1
brew install --cask google-drive > "${CASK_LOG_DIR}/google-drive.log" 2>&1
brew install --cask google-chrome > "${CASK_LOG_DIR}/google-chrome.log" 2>&1
brew install --cask microsoft-edge > "${CASK_LOG_DIR}/microsoft-edge.log" 2>&1

# Print completion message
echo "Installation complete. Logs are available at: $LOG_DIR"
