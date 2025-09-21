#!/bin/bash
# Self-extracting Debian Live target_block_device installer with persistence
# Usage:
#   sudo ./installer.run write  /dev/sdX
#   sudo ./installer.run update /dev/sdX

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
  if [[ "$user_answer" != "y" ]]; then
    echo ">>> Aborted by user."
    exit 1
  fi
}

# Function: cleanup temporary files
function cleanup()
{
  rm -f "$cephos_image"
  [[ -n "${persistence_backup_file:-}" && -f "$persistence_backup_file" ]] && rm -f "$persistence_backup_file"
}

# Function: backup persistence partition filesystem
function backup_persistence()
{
  local persist_part="${1}2"
  local mount_dir=$(mktemp -d)
  persistence_backup_file=$(mktemp)

  echo ">>> Backing up persistence partition: $persist_part"
  mount "$persist_part" "$mount_dir"
  tar -C "$mount_dir" -cpf "$persistence_backup_file" .
  sync
  umount "$mount_dir"
  rmdir "$mount_dir"
}

# Function: restore persistence partition filesystem
function restore_persistence()
{
  local persist_part="${1}2"
  local mount_dir=$(mktemp -d)

  echo ">>> Restoring persistence data into: $persist_part"
  mount "$persist_part" "$mount_dir"
  tar -C "$mount_dir" -xpf "$persistence_backup_file"
  sync
  umount "$mount_dir"
  rmdir "$mount_dir"
}

#=== MAIN SCRIPT ===#

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 <write|update> <usb-device>  (example: $0 write /dev/sdX)"
  exit 1
fi

work_mode="$1"
target_block_device="$2"
cephos_partition="${target_block_device}1"
peristence_partition="${target_block_device}2"

eof_line=$(awk '/^__IMG_BELOW__/ {print NR + 1; exit 0;}' "$0")
cephos_image=$(mktemp)
persistence_backup_file=""
trap cleanup EXIT

echo ">>> Extracting embedded image header..."
tail -n +"$eof_line" "$0" > "$cephos_image"

#=== INFO BEFORE EXECUTION ===#
print_device_info "$target_block_device"

local_img_size=$(get_image_size_mib "$cephos_image")
device_size=$(blockdev --getsize64 "$target_block_device")
device_mib=$(( device_size / 1024 / 1024 ))
persist_mib=$(( device_mib - local_img_size ))
echo ">>> Image size: ${local_img_size} MiB"
echo ">>> target_block_device device total size: ${device_mib} MiB"
echo ">>> Estimated persistence partition size: ${persist_mib} MiB"

ask_confirmation ">>> WARNING: All data on $target_block_device will be destroyed. Continue?"

#=== work_mode: update (do backup) ===#
if [[ "$work_mode" == "update" ]]
then
  backup_persistence "$target_block_device"
fi

#=== WRITING IMAGE ===#
echo ">>> Writing image to block device drive $target_block_device..."
dd if="$cephos_image" of="$target_block_device" bs=4M status=progress oflag=sync
sync
partprobe "$target_block_device"

echo ">>> Creating persistence partition..."
start_sector=$(parted -ms "$target_block_device" unit s print free | awk -F: '/free/ {start=$2} END{print start}' | sed 's/s//')

parted -s "$target_block_device" mkpart primary ext4 "${start_sector}s" 100%
sync
sleep 2

mkfs.ext4 -F -L persistence "$peristence_partition"

tmp_mount_directory=$(mktemp -d)
mount "$peristence_partition" "$tmp_mount_directory"
echo "/ union" > "$tmp_mount_directory/persistence.conf"
sync
umount "$tmp_mount_directory"
rmdir "$tmp_mount_directory"

#=== work_mode: update (restore backup) ===#
if [[ "$work_mode" == "update" ]]
then
  restore_persistence "$target_block_device"
fi

print_device_info "$target_block_device"
echo ">>> Done."
exit 0

__IMG_BELOW__
