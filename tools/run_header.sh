#!/bin/bash
# Self-extracting Debian Live root_block_device installer with persistence

set -euo pipefail

function usage()
{
    cat <<EOF
Options:
  -m: work mode (write|update)
      default: write
  -R: root block device
  -P: root persistence block device
      default: second partition on root block device
  -p: other persistence block devices in format "/dev/sdX:/var/log;/dev/sdY:/cephos"
  -s: only write CephOS image to block device
Examples:
  Write image to device and create persistence partition at same device
    $0 -R /dev/sdi
  Write image to device and create persistence partition at other device
    $0 -R /dev/sdi -P /dev/sdj
  Write image to device and create persistence partition at other device
        and map '/var/log' to another device
        and map '/var/cache' to another device
    $0 -R /dev/sdi -P /dev/sdj -p "/dev/sdm:/var/log;/dev/sdn:/var/cache"
  Update image when persistence partition at same device
    $0 -m update -R /dev/sdi
  Update image when persistence partition at other device
    $0 -s -R /dev/sdi
EOF
}

# --- options parse ---
root_block_device=""
root_persistence_block_device=""
work_mode="write"
persistences=""
write_image_only=0
while getopts ":R:P:m:p:hs" opt
do
  case ${opt} in
    h) usage ;;
    s) write_image_only=1 ;;
    R) root_block_device="${OPTARG}" ;;
    P) root_persistence_block_device="${OPTARG}" ;;
    m) work_mode="${OPTARG}" ;;
    p) persistences="${OPTARG}" ;;
   \?) echo "Error: unknown option -${OPTARG}"; exit 1 ;;
    :) echo "Error: option -${OPTARG} requires an argument"; exit 1 ;;
  esac
done

if [[ -z "$root_block_device" ]]
then
  echo "No root device specified (-R)"
  usage
  exit 1
fi
root_partition="${root_block_device}1"

root_persistence_partition_number_on_root_device=2
if [[ -z "$root_persistence_block_device" ]]
then
  root_persistence_partition="${root_block_device}${root_persistence_partition_number_on_root_device}"
else
  root_persistence_partition="${root_persistence_block_device}1"
fi

if [[ -z "$work_mode" ]]
then
  echo "No work mode specified (write|update) (-m)"
  usage
  exit 1
fi

cephos_image=$(mktemp)
persistence_backup_file=""
# --- options parse ---

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

function is_update()
{
  [[ "$work_mode" == "update" ]]
}

function persistences_exists()
{
  [[ -n "$persistences" ]]
}

function root_persistence_at_root_block_device()
{
  [[ "${root_persistence_partition}" == "${root_block_device}${root_persistence_partition_number_on_root_device}" ]]
}

function is_write_image_only()
{
  (( write_image_only ))
}

function print_device_info()
{
  local device="$1"
  echo "Device Info: $device"
  lsblk -o NAME,SIZE,PARTLABEL,LABEL,FSTYPE,MODEL,VENDOR,SERIAL,UUID,MOUNTPOINT "$device"
  echo "-------------------------------------"
}

function print_info()
{
  local local_img_size
  local device_size
  local device_mib

  local_img_size=$(get_file_size_mib "$cephos_image")
  device_size=$(blockdev --getsize64 "$root_block_device")
  device_mib=$(( device_size / 1024 / 1024 ))

  echo "CephOS image size: ${local_img_size} MiB"
  echo "$root_block_device device total size: ${device_mib} MiB"

  print_device_info "$root_block_device"

  if root_persistence_at_root_block_device
  then
    local persist_mib
    persist_mib=$(( device_mib - local_img_size ))
    echo "Estimated persistence partition size: ${persist_mib} MiB"
  else
    print_device_info "$root_persistence_block_device"
  fi

  if persistences_exists
  then
    IFS=";" read -ra entries <<< "$persistences"
    for entry in "${entries[@]}"
    do
      print_persistence_info "$entry"
    done
  fi
}

function get_file_size_mib()
{
  local filepath="$1"
  local file_size
  file_size=$(stat -c%s "$filepath")
  echo $(( file_size / 1024 / 1024 ))
}

# Function: ask user confirmation
function ask_confirmation()
{
  local prompt_msg="$1"
  read -rp "$prompt_msg (y/n): " user_answer
  if [[ "$user_answer" != "y" ]]; then
    echo "Aborted by user."
    exit 1
  fi
}

# Function: cleanup temporary files
function cleanup()
{
  rm -f "$cephos_image"
  [[ -n "${persistence_backup_file:-}" && -f "$persistence_backup_file" ]] && rm -f "$persistence_backup_file"
}
trap cleanup EXIT

function purge_device()
{
  local block_device="$1"

  echo "Purging device ${block_device}"
  dd if=/dev/zero of="${block_device}" bs=1M count=100 conv=fsync

  local disk_size=$(blockdev --getsz "${block_device}")
  local sectors_100M=$((100*1024*1024/512))    # 204800
  local seek_lvm=$((disk_size - sectors_100M))
  dd if=/dev/zero of="${block_device}" bs=512 seek=${seek_lvm} count=${sectors_100M} conv=fsync

  local size_mb=$((disk_size * 512 / 1024 / 1024))
  local seek_gpt=$((size_mb - 10))
  dd if=/dev/zero of="${block_device}" bs=1M seek=${seek_gpt} count=10 conv=fsync

  partprobe ${block_device} || blockdev --rereadpt "${block_device}" || true
  sleep 1
}

function backup_root_persistence()
{
  local mount_dir
  mount_dir=$(mktemp -d)
  persistence_backup_file=$(mktemp)

  echo "Backing up persistence partition: ${root_persistence_partition}"
  mount "${root_persistence_partition}" "${mount_dir}"
  tar -C "${mount_dir}" -cpf "${persistence_backup_file}" .
  sync
  umount "${mount_dir}"
  rmdir "${mount_dir}"
}

function restore_root_persistence()
{
  local mount_dir
  mount_dir=$(mktemp -d)

  echo "Restoring persistence data into: ${root_persistence_partition}"
  mount "${root_persistence_partition}" "${mount_dir}"
  tar -C "${mount_dir}" -xpf "${persistence_backup_file}"
  sync
  umount "${mount_dir}"
  rmdir "${mount_dir}"
}

function print_persistence_info()
{
  local entry="$1"
  local persistence_block_device
  local path
  IFS=":" read -r persistence_block_device path <<< "$entry"
  echo "${persistence_block_device} will be mount as ${path}"
  print_device_info "${persistence_block_device}"
}

function extract_cephos_image()
{
  echo "Extracting embedded image header..."
  local eof_line
  eof_line=$(awk '/^__IMG_BELOW__/ {print NR + 1; exit 0;}' "$0")
  tail -n +"$eof_line" "$0" > "$cephos_image"
}

function write_cephos_to_root()
{
  purge_device "${root_block_device}"
  echo "Writing image to block device drive ${root_block_device}..."
  dd if="${cephos_image}" of="${root_block_device}" bs=4M status=progress oflag=sync || { echo "Error writing image"; exit 1; }
  sync
  partprobe "${root_block_device}" &> /dev/null
  parted -s "${root_block_device}" set 1 boot on
}

function make_persistence_conf()
{
  local persistence_partition="$1"
  local conf_str="$2"
  local tmp_mount_directory

  echo "Creating persistence.conf on partition ${persistence_partition} with content: '${conf_str}'"

  mkfs.ext4 -F -L persistence "$persistence_partition"
  tmp_mount_directory=$(mktemp -d)
  mount "$persistence_partition" "$tmp_mount_directory"
  echo "${conf_str}" > "$tmp_mount_directory/persistence.conf"
  sync
  umount "$tmp_mount_directory"
  rmdir "$tmp_mount_directory"
}

function write_root_persistence_to_root_block_device()
{
  echo "Creating persistence partition..."

  local start_sector
  start_sector=$(parted -ms "${root_block_device}" unit s print free | awk -F: '/free/ {start=$2} END{print start}' | sed 's/s//')
  parted -s "${root_block_device}" mkpart primary ext4 "${start_sector}s" 100%
  partprobe "${root_block_device}"
  sync
  sleep 2
}

function make_persistence()
{
  local persistence_block_device="$1"
  local conf_str="$2"

  echo "Creating partition on device ${persistence_block_device}..."

  parted -s "${persistence_block_device}" mklabel gpt
  parted -s "${persistence_block_device}" mkpart primary ext4 0% 100%
  partprobe "$persistence_block_device"
  sync
  sleep 2

  make_persistence_conf "${persistence_block_device}1" "${conf_str}"
}

function make_persistences_wrapper()
{
  local entry="$1"
  local persistence_block_device
  local path
  IFS=":" read -r persistence_block_device path <<< "$entry"

  make_persistence "${persistence_block_device}" "${path}"
}

function make_persistences()
{
  if persistences_exists
  then
    IFS=";" read -ra entries <<< "$persistences"
    for entry in "${entries[@]}"
    do
      make_persistences_wrapper "$entry"
    done
  fi
}

function block_device_is_only_cephos()
{
  local device_path="$1"
  local partition_count
  partition_count=$(lsblk -ln -o NAME "${device_path}" | grep -c "^$(basename "${device_path}")[0-9]")
  if (( partition_count == 3 ))
  then
      return 0
  else
      return 1
  fi
}

# === script ===

if is_update && is_write_image_only
then
  echo "No point in updating if you just want to write the image to the device"
  echo "Run '$0 -R ${root_block_device} -s'"
  exit 1
fi

if is_update && block_device_is_only_cephos "${root_block_device}"
then
  echo "Updating only makes sense if the persistence partition is on the same device"
  echo "Run '$0 -R ${root_block_device} -s'"
  exit 1
fi

if is_update && persistences_exists
then
  echo "No point in updating other partitions when updating the CephOS partition. Don't specify them on the command line"
  exit 1
fi

echo "--- >>>"

extract_cephos_image
print_info
ask_confirmation "WARNING: All data on block devices will be destroyed. Continue?"

#=== work_mode: update (do backup) ===#
if is_update
then
  backup_root_persistence "$root_block_device"
fi

#=== WRITING IMAGE ===#
write_cephos_to_root

if ! is_write_image_only
then
  if root_persistence_at_root_block_device
  then
    write_root_persistence_to_root_block_device
    make_persistence_conf "${root_persistence_partition}" "/ union"
  else
    make_persistence "${root_persistence_block_device}" "/ union"
  fi

  make_persistences
fi

#=== work_mode: update (restore backup) ===#
if is_update
then
  restore_root_persistence "$root_block_device"
fi

echo "Done."
print_info
echo "<<< ---"

exit 0

__IMG_BELOW__
