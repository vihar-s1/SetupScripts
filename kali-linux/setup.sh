#!/usr/bin/env bash

source ./configs/functions.sh

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


SETUP_PERSISTENCE=false


# Process Arguments
for arg in "$@"; 
do
  case $arg in
    -h|--help)
      echo "Usage: $0 [OPTION]"
      echo "Setup anonsurf on kali linux."
      echo "Options:"
      echo "  -h, --help  Display this help message."
      exit 0
      ;;
    -p|--persistence)
      SETUP_PERSISTENCE=true
      ;;
  esac
done

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
log_info "anonsurf setup completed successfully."

if [ SETUP_PERSISTENCE ]; then
  log_info "setting up persistence..."
  sudo ./usbPersistence.sh
fi