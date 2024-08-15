#!/usr/bin/env bash

# root privileges are required to setup
if [ "$EUID" -ne 0 ]; then
    echo -e "script requires root privilege.\nusage: sudo ./setup.sh"
    exit 1
fi

ANONSURF_DIR="kali-anonsurf"
DRIVE_PATH="/dev/sdb"
PARTITION_START="3.5GiB"
PARTITION_END="43.5GiB"

echo "updating packages..."
apt-get update

echo "upgrading packages..."
apt-get upgrade

echo "installing gedit..."
apt-get install gedit

echo "cloning anonsurf..."
git clone https://github.com/und3rf10w/kali-anonsurf.git

if [ -e "${ANONSURF_DIR}" ]; then
    echo -e "repository cloned...installing anonsurf..."
    cd "${ANONSURF_DIR}"
    ./installer.sh
    cd ..
else
    echo "directory not found: ${ANONSURF_DIR}"
fi

# Check which of the two works
# - fdisk ${usb} <<< $(printf ""n\np\n\n\n\nw)
# - part ${usb} mkparted primary ${PARTITION_START} ${PARTITION_END}

MOUNT_PARTITION="${DRIVE_PATH}3"
MOUNT_PATH="/mnt/my_usb"

mkfs.ext4  -L persistence "${MOUNT_PARTITION}"

mkdir -p "${MOUNT_PATH}"
mount "${MOUNT_PARTITION}" ${MOUNT_PATH}"
echo "/ union" | sudo tee "${MOUNT_PATH}/persistence.conf"
umount "${MOUNT_PARTITION}"
