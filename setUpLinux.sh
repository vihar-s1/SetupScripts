#!/usr/bin/env bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script requires superuser privileges. Please enter your root password to continue..."
    sudo -i "$(realpath $0)"
    if [ $? -ne 0 ]; then
        echo "Error logging in as root user. Aborting..."
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

# Updating Package Manager
log_info "Updating package lists..."
apt update >> "$TMP" 2>&1
if [ $? -ne 0 ]; then
    log_error "Failed to update package lists. Aborting..."
    exit 1
fi

# Installing Formulas
log_info "Installing formulas..."
# List of formulas to install
formulas=(
    "python3"
    "gradle"
    "nodejs"
    "gedit"
    "nano"
    "elasticsearch"
    "kibana"
    "mongodb"
    "zookeeper"
    "kafka"
)
for formula in "${formulas[@]}"; do
    apt install -y "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1 &
done
wait # wait for all formula installation to complete
log_info "Completed installing all formulas. Check logs to see their status"

# Installing Casks
log_info "Installing casks..."
# List of casks to install
casks=(
    "sublime-text"
    "intellij-idea"
    "code"
    "docker"
    "virtualbox"
    "mongodb-compass"
    "vlc"
    "spotify"
    "whatsapp"
    "google-drive"
    "google-chrome-stable"
    "microsoft-edge"
)
for cask in "${casks[@]}"; do
    apt install -y "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1 &
done
wait # wait for all cask installation to complete
log_info "Completed installing all casks. Check logs to see their status"

# Print completion message
log_info "Installation complete. Logs are available at: $LOG_DIR"
