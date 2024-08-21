#!/usr/bin/env bash

source functions.sh

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo $0"
    exit 1
fi

DRIVE_PATH="/dev/sdb3"
LUKS_HEADER_BACKUP_FILE="luksheader.back"


# Backup LUKS keyslots and encrypt them
log_info "backing up LUKS header..."
cryptsetup luksHeaderBackup --header-backup-file "${LUKS_HEADER_BACKUP_FILE}" "${DRIVE_PATH}"
openssl enc -e -aes-256-cbc -in luksheader.back -out "${LUKS_HEADER_BACKUP_FILE}.enc"

# install and configure cryptsetup-nuke-password
log_info "installing cryptsetup-nuke-password..."
apt install -y cryptsetup-nuke-password

log_info "configuring nuke password..."
dpkg-reconfigure cryptsetup-nuke-password

# The configured nuke password will be stored in the initrd and will be usable 
# with all encrypted partitions that you can unlock at boot time.
