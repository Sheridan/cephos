#!/usr/bin/env bash

set -euo pipefail

disk_size="8G"
memory_mb=8192
cpus=2

base_vnc_disp=10   # :10, :11 ...

qemu_tap_interfaces_prefix="tap_qemu"
qemu_bridge_interface="br_qemu"

declare -A quemu_pids=()

conf_str="${1:-}"

if [[ -z "$conf_str" ]]; then
  echo "Использование: $0 'one:/dev/sdm,/dev/sdn;two:/dev/sdg,/dev/sdj'"
  echo "Формат строки: 'имя:флешка,флешка2...;имя1:флешка3,флешка4,флешка5...' и так далее"
  exit 1
fi

mkdir -p tmp

function create_qemu_hdd()
{
  local img="$1"
  if [[ ! -f "$img" ]]
  then
    echo "Создаю $img (${disk_size})..."
    qemu-img create -f qcow2 "$img" ${disk_size}
  fi
}

function up_vm_tap_interface()
{
  local vm_tap_interface="$1"
  echo "Создаю TAP-интерфейс ${vm_tap_interface}..."
  ip tuntap add dev "${vm_tap_interface}" mode tap user "$(id -un)"
  ip link set "${vm_tap_interface}" master "${qemu_bridge_interface}"
  ip link set "${vm_tap_interface}" up
}

function down_vm_tap_interface()
{
  local vm_tap_interface="$1"
  echo "Удаляю TAP-интерфейс ${vm_tap_interface}..."
  ip link set "${vm_tap_interface}" down 2>/dev/null || true
  ip link delete "${vm_tap_interface}" 2>/dev/null || true
}

function run_vm()
{
  local vmname=$1; shift
  local disks=("$@")

  local vm_tap_interface="${qemu_tap_interfaces_prefix}_${vmname}"

  local qemu_hdd_0="tmp/${vmname}-hdd0.img"
  local qemu_hdd_1="tmp/${vmname}-hdd1.img"
  create_qemu_hdd "$qemu_hdd_0"
  create_qemu_hdd "$qemu_hdd_1"

  local drives=()
  for rawdev in "${disks[@]}"
  do
    if [[ ! -b "$rawdev" ]]
    then
      echo "Ошибка: $rawdev не блочное устройство"
      exit 1
    fi
    drives+=("-drive" "if=virtio,file=$rawdev,format=raw,cache=none")
  done

  drives+=("-drive" "if=virtio,file=$qemu_hdd_0,format=qcow2")
  drives+=("-drive" "if=virtio,file=$qemu_hdd_1,format=qcow2")

  local idx=$((vm_index++))
  local vnc_disp=$((base_vnc_disp + idx))
  local mac="52:54:00:aa:bb:$(printf '%02x' $idx)"

  echo ">>> Запуск ВМ $vmname (VNC :$vnc_disp)"
  up_vm_tap_interface "$vm_tap_interface"
  (
    qemu-system-x86_64 \
      -enable-kvm \
      -m ${memory_mb} \
      -smp ${cpus} \
      "${drives[@]}" \
      -boot order=a \
      -netdev tap,id=net0,ifname=${vm_tap_interface},script=no,downscript=no \
      -device virtio-net-pci,netdev=net0,mac=${mac} \
      -display vnc=:$vnc_disp \
      -name "${vmname}" \
  ) &
  local pid=$!
  quemu_pids[$pid]="${vm_tap_interface}"
}

function parse_vm_conf()
{
  local vmdef="$1"
  local name="${vmdef%%:*}"
  local disks_str="${vmdef#*:}"
  IFS=',' read -ra disk_list <<< "$disks_str"
  run_vm "$name" "${disk_list[@]}"
}


# --- Main loop ---
vm_index=0
IFS=';' read -ra vms <<< "$conf_str"
for vmdef in "${vms[@]}"
do
  parse_vm_conf "${vmdef}"
done

for pid in "${!quemu_pids[@]}"
do
  if wait "$pid"
  then
    down_vm_tap_interface "${quemu_pids[$pid]}"
  else
    echo "${quemu_pids[$pid]} завершился с ошибкой"
    down_vm_tap_interface "${quemu_pids[$pid]}"
  fi
done

wait
