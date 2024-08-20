#!/usr/bin/env bash

# root pr# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo $0"
    exit 1
fi

ANONSURF_DIR="kali-anonsurf"

LOG_DIR="$HOME/Desktop/${script_name}-logs"
APT_GET_DIR="${LOG_DIR}/apt-get.log"
GIT_LOG="${LOG_DIR}/git.log"
ANONSURF_LOG="${LOG_DIR}/anonsurf.log"

# Function to log errors
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
}

# Function to log informational messages
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_info "updating packages..."
apt-get update >> "${APT_GET_DIR}" 2>&1

log_info "upgrading packages..."
apt-get upgrade >> "${APT_GET_DIR}" 2>&1

log_info "clonning anonsurf..."
git clone https://github.com/und3rf10w/kali-anonsurf.git >> "${GIT_LOG}" 2>&1

if [ -e "${ANONSURF_DIR}" ]; then
  log_info "installing anonsurf..."
  cd ${ANONSURF_DIR}
  ./installer.sh >> "${ANONSURF_LOG}" 2>&1
  cd ..
else
  log_error "anonsurf directory not found: ${ANONSURF_DIR}"
fi
