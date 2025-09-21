#!/bin/bash

set -euo pipefail

disk_size="8G"
base_ssh_port=2200
base_http_port=8000
base_vnc_disp=10   # :10, :11 ...

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

function run_vm()
{
  local vmname=$1; shift
  local disks=("$@")

  local qemu_hdd_0="tmp/${vmname}-hdd0.img"
  local qemu_hdd_1="tmp/${vmname}-hdd1.img"
  create_qemu_hdd "$qemu_hdd_0"
  create_qemu_hdd "$qemu_hdd_1"

  local drives=()
  for rawdev in "${disks[@]}"; do
    if [[ ! -b "$rawdev" ]]; then
      echo "Ошибка: $rawdev не блочное устройство"
      exit 1
    fi
    drives+=("-drive" "if=virtio,file=$rawdev,format=raw,cache=none")
  done

  drives+=("-drive" "if=virtio,file=$qemu_hdd_0,format=qcow2")
  drives+=("-drive" "if=virtio,file=$qemu_hdd_1,format=qcow2")

  local idx=$((vm_index++))
  local ssh_port=$((base_ssh_port + idx))
  local http_port=$((base_http_port + idx))
  local vnc_disp=$((base_vnc_disp + idx))
  local mac="52:54:00:aa:bb:$(printf '%02x' $idx)"

  echo ">>> Запуск ВМ $vmname (SSH:$ssh_port, HTTP:$http_port, VNC :$vnc_disp)"
  qemu-system-x86_64 \
    -enable-kvm \
    -m 8192 \
    -smp 2 \
    "${drives[@]}" \
    -boot order=a \
    -nic user,hostfwd=tcp::${ssh_port}-:22,hostfwd=tcp::${http_port}-:8080,model=virtio-net-pci,mac=${mac} \
    -display vnc=:$vnc_disp \
    -name "${vmname}" \
    &
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

wait
