#!/usr/bin/env bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script requires superuser privileges. Please Enter root-user Password..."
    sudo -iu root "$(realpath $0)"
    if [ $? -ne 0 ]; then
        echo "Error logging as root user. Aborting..."
        exit 1
    fi
    exit 0 # Exit safely since script ran successfully with sudo access
fi

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
: > "$TMP"

# Function to log errors
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$TMP"
}

# Function to log informational messages
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$TMP"
}

# Homebrew Installation and Update
if ! command -v brew &> /dev/null; then
    log_info "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$TMP" 2>&1 &
    wait $!
    if [ $? -ne 0 ]; then
        log_error "Failed to install Homebrew."
        exit 1
    fi
else
    current_version=$(brew --version | awk 'NR==1 {print $2}')
    log_info "Found Homebrew version: ${current_version}. Attempting to Update..."
    brew update >> "$TMP" 2>&1 &
    wait $!
    if [ $? -ne 0 ]; then
        log_error "Failed to update Homebrew."
        exit 1
    fi
fi

# Fetching Taps
log_info "Fetching taps..."
{ brew tap homebrew/services; brew tap homebrew/cask; brew tap elastic/tap; brew tap mongodb/tap; } >> "${TAP_LOG_DIR}/tap.log" 2>&1

# Installing Formulas
log_info "Installing formulas..."
# List of formulas to install
formulas=(
    "python3"
    "gradle"
    "node"
    "gedit"
    "nano"
    "elasticsearch-full"
    "kibana-full"
    "mongosh"
    "mongodb-community"
    "zookeeper"
    "kafka"
)
for formula in "${formulas[@]}"; do
    brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1 &
done
wait # wait for all formula installation to complete
log_info "Completed Installing all formulas. Check logs to see their status"

# Installing Casks
log_info "Installing casks..."
# List of casks to install
casks=(
    "sublime-text"
    "intellij-idea"
    "intellij-idea-ce"
    "visual-studio-code"
    "docker"
    "virtualbox"
    "mongodb-compass"
    "vlc"
    "spotify"
    "whatsapp"
    "google-drive"
    "google-chrome"
    "microsoft-edge"
)
for cask in "${casks[@]}"; do
    brew install --cask "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1 &
done
wait # wait for all cask installation to complete
log_info "Completed Installing all casks. Check logs to see their status"

# Print completion message
log_info "Installation complete. Logs are available at: $LOG_DIR"
