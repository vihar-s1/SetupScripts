#!/usr/bin/env bash

# Set script name
script_name=$(basename "$0")
script_name="${script_name%.*}"

# Set log directory
LOG_DIR="$HOME/Desktop/${script_name}-logs"
TAP_LOG_DIR="${LOG_DIR}/taps"
FORMULA_LOG_DIR="${LOG_DIR}/formulas"
CASK_LOG_DIR="${LOG_DIR}/casks"
BREW_LOG="${LOG_DIR}/brew.log"

# Create log directories
mkdir -p "${TAP_LOG_DIR}" "${FORMULA_LOG_DIR}" "${CASK_LOG_DIR}"

# Function to log errors
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
}

# Function to log informational messages
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
}

# BEFORE EVERYTHING, MAKE  SURE TO INSTALL xcode
xcode-select --install >> "${BREW_LOG}" 2>&1

# Homebrew Installation and Update
if ! command -v brew &> /dev/null; then
    log_info "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "${BREW_LOG}" 2>&1
    if [ $? -ne 0 ]; then
        log_error "Failed to install Homebrew."
        exit 1
    fi
else
    current_version=$(brew --version | awk 'NR==1 {print $2}')
    log_info "Found Homebrew version: ${current_version}. Attempting to Update..."

    if ! brew update >> "${BREW_LOG}" 2>&1; then
        log_error "Failed to update Homebrew."
        exit 1
    else
        if ! brew upgrade >> "${BREW_LOG}" 2>&1; then
            log_error "update successful, upgrade failed."
        else
            new_version=$(brew --version | awk 'NR==1 {print $2}')
            log_info "Homebrew Update successful. current installed version: ${new_version}"
        fi
    fi
fi

# Fetching Taps
log_info "Fetching taps..."
{ brew tap homebrew/services; brew tap elastic/tap; brew tap mongodb/brew; } >> "${TAP_LOG_DIR}/tap.log" 2>&1

# Installing Formulas
log_info "Installing formulas..."
# List of formulas to install
formulas=(
    "python3"               # Languages
    "git"
    "git-lfs"
    "gradle"                # Package Manager
    "maven"
    "node"
    "gedit"                 # Editors
    "nano"
    "elasticsearch-full"    # Tools and Libraries
    "kibana-full"
    "mongosh"
    "mongodb-community"
    "zookeeper"
    "kafka"
)

    # Installing formulas needs to be serialized
    # since running them in parallel can cause issues due to common dependencies.
for formula in "${formulas[@]}"; do
    # brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1 &
    log_info "installing formula: ${formula}"
    brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1
done
wait # wait for all formula installation to complete
log_info "Completed Installing all formulas. Check logs to see their status"

# Installing Casks
log_info "Installing casks..."
# List of casks to install
casks=(
    "sublime-text"      # Editors
    "intellij-idea"
    "intellij-idea-ce"
    "visual-studio-code"
    "docker"            # GUI tools
    "postman"
    "virtualbox"
    "mongodb-compass"
    "vlc"               # Personal Use Apps
    "spotify"
    "whatsapp"
    "google-drive"
    "google-chrome"
    "microsoft-edge"
    "jellybeansoup-netflix"
    "slack"
)
for cask in "${casks[@]}"; do
    brew install --cask "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1 &
done
wait # wait for all cask installation to complete
log_info "Completed Installing all casks. Check logs to see their status"

log_info "Running additional Commands..."

git lfs install

# Print completion message
log_info "Installation complete. Logs are available at: $LOG_DIR"
