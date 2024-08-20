#!/usr/bin/env bash

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo $0"
    exit 1
fi

DRIVE_PATH="/dev/sdb"
PARTITION_START="3.5GiB"
PARTITION_END="43.5GiB"

# Function to log errors
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
}

# Function to log informational messages
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_info "creating partition..."
# Check which of the two works
# - fdisk ${usb} <<< $(printf ""n\np\n\n\n\nw)
# - parted ${usb} mkpart primary ${PARTITION_START} ${PARTITION_END}

MOUNT_PARTITION="${DRIVE_PATH}3"
MOUNT_FOLDER="my_usb"
DEV_MAPPER_PATH="/dev/mapper/${MOUNT_FOLDER}"
MOUNT_PATH="/mnt/${MOUNT_FOLDER}"

# Encrypt the partition with LUKS
log_info "encrypting the partition: ${MOUNT_PARTITION} with LUKS"
cryptsetup --verbose --verify-passphrase luksFormat "${MOUNT_PARTITION}"
cryptsetup luksOpen "${MOUNT_PARTITION}" "${MOUNT_FOLDER}"

log_info "setting ext4 persistence at partition: ${MOUNT_PARTITION}"
mkfs.ext4  -L persistence "${DEV_MAPPER_PATH}"
e2label "${DEV_MAPPER_PATH}" persistence

log_info "mounting the partition at path: ${MOUNT_PATH}"
mkdir -p "${MOUNT_PATH}"
mount "${DEV_MAPPER_PATH}" "${MOUNT_PATH}"
echo "/ union" | sudo tee "${MOUNT_PATH}/persistence.conf"

log_info "unmounting the partition"
umount "${DEV_MAPPER_PATH}"

log_info "closing the encrypted partition"
cryptsetup luksClose "${DEV_MAPPER_PATH}"

echo -e "\nEncrypted persistence setup completed successfully."
echo -e "You can now reboot your system and boot from the USB drive."
echo -e "After booting, you can access the encrypted persistence partition by providing the passphrase."

echo -e "Do you want to setup Nuke Password/Self-Destruct Password? (y/n)"
read -r NUKE_PASSWORD

if [ "$NUKE_PASSWORD" == "y" || "$NUKE_PASSWORD" == "Y" ]; then
    sudo bash components/nukePassword.sh
fi

echo -e "\nDo you want to reboot now? (y/n)"
read -r REBOOT
