#!/bin/bash

# Set script name
script_name=$(basename "$0")
script_name="${script_name%.*}"

# Set log directory
CWD=$(pwd)
LOG_DIR="$CWD/logs"
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
    brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1
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
    brew install "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1
done
wait # wait for all cask installation to complete
log_info "Completed installing all casks. Check logs to see their status"

# Print completion message
log_info "Installation complete. Logs are available at: $LOG_DIR"
