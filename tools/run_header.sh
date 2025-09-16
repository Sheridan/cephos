#!/bin/bash
# Simple self-extracting Debian Live USB installer with persistence
# Usage: sudo ./installer.run /dev/sdX

set -euo pipefail

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

# Temporary image extraction
ARCHIVE_LINE=$(awk '/^__IMG_BELOW__/ {print NR + 1; exit 0;}' "$0")
IMG=$(mktemp)

cleanup()
{
  rm -f "$IMG"
}
trap cleanup EXIT

echo ">>> Extracting embedded image to a temporary file..."
tail -n +$ARCHIVE_LINE "$0" > "$IMG"

echo ">>> Writing image to USB drive $USB..."
dd if="$IMG" of="$USB" bs=4M status=progress oflag=sync
sync
partprobe "$USB"

echo ">>> Creating persistence partition..."
# Find first available free sector
START_SECTOR=$(parted -ms "$USB" unit s print free | awk -F: '/free/ {start=$2} END{print start}' | sed 's/s//')

# Create partition from free space
parted -s "$USB" mkpart primary ext4 "${START_SECTOR}s" 100%

# Wait for kernel to register new partition
sleep 2
NEW_PART=$(ls ${USB}* | grep -E "${USB}.$" | sort | tail -1)

mkfs.ext4 -F -L persistence "$NEW_PART"

# Create persistence.conf
MNTDIR=$(mktemp -d)
mount "$NEW_PART" "$MNTDIR"
echo "/ union" > "$MNTDIR/persistence.conf"
umount "$MNTDIR"
rmdir "$MNTDIR"

echo ">>> Done."
exit 0

__IMG_BELOW__
