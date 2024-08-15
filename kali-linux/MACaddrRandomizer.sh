#!/usr/bin/env bash

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo ./setup.sh"
    exit 1
fi

# Function to log errors
log_error() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
}

# Function to log informational messages
log_info() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
}


# Checking if network interface card is provided or not
if [ $# != 1 ]; then
    log_error "Network Interface Card not provided!!"
    echo "Usage: ${0} <NIC>"
    exit 1
fi

NIC=$1
# validate the provided network interface card
NIC_EXISTS=$(ifconfig "${NIC}")
if [ $? != 0 ]; then
    log_error "invalid network interface card: \"${NIC}\""
    exit 1
fi

if !command -v "macchanger" >/dev/null 2>&1; then
    log_error "macchanger not found"
    log_info "installing macchanger"
    apt-get install macchanger
fi

while true
do
    ifconfig "${NIC}" down
    macchanger -r "${NIC}" | grep "New MAC"
    iwconfig "${NIC}" mode monitor
    ifconfig "${NIC}" up
    sleep 5
done
