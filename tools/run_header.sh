#!/bin/bash
# Self-extracting Debian Live USB installer with persistence
# Usage: sudo ./installer.run /dev/sdX

set -euo pipefail

#=== FUNCTIONS ===#

# Function: print device info (size, partitions, fs type)
function print_device_info()
{
  local device="$1"
  echo ">>> Device Info: $device"
  lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT "$device"
  echo "-------------------------------------"
}

# Function: get image size in MiB
function get_image_size_mib()
{
  local image_file="$1"
  local image_size
  image_size=$(stat -c%s "$image_file")
  echo $(( image_size / 1024 / 1024 ))
}

# Function: ask user confirmation
function ask_confirmation()
{
  local prompt_msg="$1"
  read -rp "$prompt_msg (y/n): " user_answer
  if [[ "$user_answer" != "y" ]]
  then
    echo ">>> Aborted by user."
    exit 1
  fi
}

# Function: cleanup temporary files
cleanup()
{
  rm -f "$IMG"
}

#=== MAIN SCRIPT ===#

if [ "$(id -u)" -ne 0 ]
then
    echo "Run as root"
    exit 1
fi

if [ $# -ne 1 ]
then
    echo "Usage: $0 <usb-device>  (for example: /dev/sdX)"
    exit 1
fi

USB="$1"

ARCHIVE_LINE=$(awk '/^__IMG_BELOW__/ {print NR + 1; exit 0;}' "$0")
IMG=$(mktemp)
trap cleanup EXIT

echo ">>> Extracting embedded image header..."
tail -n +$ARCHIVE_LINE "$0" > "$IMG"

#=== INFO BEFORE EXECUTION ===#
print_device_info "$USB"

local_img_size=$(get_image_size_mib "$IMG")
device_size=$(blockdev --getsize64 "$USB")
device_mib=$(( device_size / 1024 / 1024 ))
persist_mib=$(( device_mib - local_img_size ))
echo ">>> CephOS image size: ${local_img_size} MiB"
echo ">>> USB device total size: ${device_mib} MiB"
echo ">>> Estimated persistence partition size: ${persist_mib} MiB"

ask_confirmation ">>> WARNING: All data on $USB will be destroyed. Continue?"

#=== WRITING IMAGE ===#
echo ">>> Writing image to USB drive $USB..."
dd if="$IMG" of="$USB" bs=4M status=progress oflag=sync
sync
partprobe "$USB"

echo ">>> Creating persistence partition..."
START_SECTOR=$(parted -ms "$USB" unit s print free | awk -F: '/free/ {start=$2} END{print start}' | sed 's/s//')

parted -s "$USB" mkpart primary ext4 "${START_SECTOR}s" 100%
sleep 2

NEW_PART=$(ls ${USB}* | grep -E "${USB}.$" | sort | tail -1)

mkfs.ext4 -F -L persistence "$NEW_PART"

MNTDIR=$(mktemp -d)
mount "$NEW_PART" "$MNTDIR"
echo "/ union" > "$MNTDIR/persistence.conf"
umount "$MNTDIR"
rmdir "$MNTDIR"

echo ">>> Done."
exit 0

__IMG_BELOW__
