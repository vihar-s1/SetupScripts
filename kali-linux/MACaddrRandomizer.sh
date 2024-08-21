#!/usr/bin/env bash

source ./components/functions.sh

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo ./setup.sh"
    exit 1
fi


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
