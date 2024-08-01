#!/usr/bin/env bash

#----- SCRIPT CONFIG PARAMETERS -----
# List of all taps
TAPS=(
    "homebrew/services" "elastic/tap"
    "mongodb/brew" "quarkusio/tap"
)

# List of formulas to install
FORMULAS=(
    "python3" "git" "git-lfs"
    "gradle" "maven" "node"
    "gedit" "nano"
    "elasticsearch-full" "kibana-full"
    "mongosh" "mongodb-community"
    "redis"
    "zookeeper" "kafka" "quarkus" 
    "graphana" "graphana-agent"
    "influxdb" "influxdb-cli"
)

# List of casks to install
CASKS=(
    "sublime-text" "intellij-idea" "intellij-idea-ce" "visual-studio-code"
    "docker" "minikube"
    "postman" "mongodb-compass"
    "vlc" "spotify" "whatsapp" "telegram"
    "google-drive" "google-chrome" "microsoft-edge"
    "jellybeansoup-netflix"
    "slack" "balenaetcher" "github"
    "wireshark"
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

#---------- HOMEBREW INSTALLATION AND UPDATE ----------#
if ! command -v brew &> /dev/null; then
    log_info "Homebrew is not installed. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "${BREW_LOG}" 2>&1
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

#---------- FETCHING TAPS ----------#
log_info "Fetching taps..."

for tap in "${TAPS[@]}"; do
    log_info "tapping: ${tap}"
    brew tap "${tap}" >> "${TAP_LOG_DIR}/tap.log" 2>&1
done
wait # wait for all repositories to be tapped
log_info "Completed tapping the repositories (taps). Check logs to see their status"

#---------- INSTALLING FORMULAS ----------#
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

#---------- INSTALLING CASKS ----------#
log_info "Installing casks..."

for cask in "${CASKS[@]}"; do
    brew install --cask "$cask" >> "${CASK_LOG_DIR}/${cask}.log" 2>&1 &
done
wait # wait for all cask installation to complete
log_info "Completed Installing all casks. Check logs to see their status"

log_info "Installation complete. Logs are available at: $LOG_DIR"


#---------- RUNNING ADDDITIONAL SETUP COMMANDS ----------#
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

# Disabling Elasticsearch ml functionalities
es_config_path=$(brew info elasticsearch | grep Config | awk 'NR==1 {print $2}')
es_config_path="${es_config_path%/}" # Remove trailing '/' if any
es_config_file="${es_config_path}/elasticsearch.yml"

if [ -e "${es_config_file}" ]; then
	log_info "disabling ES Machine Learning functionalities at: ${es_config_file}"
	echo -e "\nxpack.ml.enabled: false" >> ${es_config_file}
else
	log_error "could not locate ES config file at: ${es_config_file}"
fi

#---------- IMPORTING CUSTOM TERMINAL PROFILE ----------#
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

