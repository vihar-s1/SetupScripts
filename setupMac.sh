#!/usr/bin/env bash

#----- SCRIPT CONFIG PARAMETERS -----
# List of formulas to install
FORMULAS=(
    "python3" "git" "git-lfs"
    "gradle" "maven" "node"
    "gedit" "nano"
    "elasticsearch-full" "kibana-full"
    "mongosh" "mongodb-community"
    "zookeeper" "kafka"
)

# List of casks to install
CASKS=(
    "sublime-text" "intellij-idea" "intellij-idea-ce" "visual-studio-code"
    "docker" "postman" "mongodb-compass"
    "vlc" "spotify" "whatsapp"
    "google-drive" "google-chrome" "microsoft-edge"
    "jellybeansoup-netflix"
    "slack"
)

TERMINAL_PROFILE="./configs/Custom.terminal"
BASH_PROFILE="./configs/.bash_profile"
#----- SCRIPT CONFIG PARAMETERS -----

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
    # Attempting to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
      # For Apple Silicon Macs
      log_info "Configuring Homebrew in PATH for Apple Silicon Mac..."
      export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    current_version=$(brew --version | awk 'NR==1 {print $2}')
    log_info "Found Homebrew version: ${current_version}. Attempting to Update..."

    if ! brew update >> "${BREW_LOG}" 2>&1; then
        log_error "Failed to update Homebrew."
        exit 1
    else
        brew upgrade >> "${BREW_LOG}" 2>&1
        brew upgrade --cask >> "${BREW_LOG}" 2>&1
        new_version=$(brew --version | awk 'NR==1 {print $2}')
        log_info "Homebrew Update successful. current installed version: ${new_version}"
    fi
fi

# Fetching Taps
log_info "Fetching taps..."
{ brew tap homebrew/services; brew tap elastic/tap; brew tap mongodb/brew; } >> "${TAP_LOG_DIR}/tap.log" 2>&1

# Installing FORMULAS
log_info "Installing formulas..."

    # Installing formula needs to be serialized
    # since running them in parallel can cause issues due to common dependencies.
for formula in "${FORMULAS[@]}"; do
    # brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1 &
    log_info "installing formula: ${formula}"
    brew install "$formula" >> "${FORMULA_LOG_DIR}/${formula}.log" 2>&1
done
wait # wait for all formula installation to complete
log_info "Completed Installing all formulas. Check logs to see their status"

# Installing Casks
log_info "Installing casks..."

for cask in "${CASKS[@]}"; do
    brew install --cask "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1 &
done
wait # wait for all cask installation to complete
log_info "Completed Installing all casks. Check logs to see their status"

log_info "Installation complete. Logs are available at: $LOG_DIR"

log_info "Running additional Commands..."

# Installing git lfs
git lfs install
# moving bash profile file to root location

if [ -e "${BASH_PROFILE}" ]; then
    log_info "configuring bash profile..."
    cp "${BASH_PROFILE}" ~/.bash_profile
else
    log_error "bash profile not found at: ${BASH_PROFILE}"
fi

log_info "Importing custom terminal profile..."
if [ -x "./macOS-scripts/configureTerminal.sh" ]; then

    if ! ./macOS-scripts/configureTerminal.sh $TERMINAL_PROFILE; then
        log_error "Error importing terminal profile."
    else
        log_info "Profile imported successfully."
    fi
else
    log_error "Could not find configureTerminal.sh or it is not executable."
fi

