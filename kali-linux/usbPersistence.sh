#!/usr/bin/env bash

source ./components/functions.sh

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo $0"
    exit 1
fi

DRIVE_PATH="/dev/sdb"
PARTITION_START="3.5GiB"
PARTITION_END="43.5GiB"


log_info "creating partition..."
# Check which of the two works
# - fdisk ${usb} <<< $(printf ""n\np\n\n\n\nw)
parted ${usb} mkpart primary ${PARTITION_START} ${PARTITION_END}

MOUNT_PARTITION="${DRIVE_PATH}3"
MOUNT_PATH="/mnt/my_usb"

log_info "setting ext4 persistence at partition: ${MOUNT_PARTITION}"
mkfs.ext4  -L persistence "${MOUNT_PARTITION}"

log_info "mounting the partition at path: ${MOUNT_PATH}"
mkdir -p "${MOUNT_PATH}"
mount "${MOUNT_PARTITION}" ${MOUNT_PATH}"
echo "/ union" | sudo tee "${MOUNT_PATH}/persistence.conf"

log_info "unmounting the partition"
umount "${MOUNT_PARTITION}"
