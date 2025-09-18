#!/bin/bash
# run-ceph-vm.sh
# Запуск QEMU для теста Ceph c загрузкой с USB‑флешки и двумя HDD

set -euo pipefail

if [[ $# -ne 1 ]]
then
  echo "Использование: $0 /dev/sdX"
  exit 1
fi
flash_blk_dev="$1"
qemu_hdd_0="tmp/ceph-hdd0.img"
qemu_hdd_1="tmp/ceph-hdd1.img"


function check_flash()
{
  if [[ ! -b "$flash_blk_dev" ]]
  then
    echo "Ошибка: $flash_blk_dev не найдено или не является блочным устройством"
    exit 1
  fi
}

function create_quemu_hdd()
{
  local qemu_hdd="$1"
  if [[ ! -f "$qemu_hdd" ]]
  then
    echo "Создаю $qemu_hdd (1G)..."
    qemu-img create -f qcow2 "$qemu_hdd" 1G
  fi
}

function run_qemu()
{
  echo "Запуск QEMU (флешка: $flash_blk_dev)"
  qemu-system-x86_64 \
      -enable-kvm \
      -m 8192 \
      -smp 2 \
      -drive if=virtio,file="$flash_blk_dev",format=raw,cache=none \
      -drive if=virtio,file="$qemu_hdd_0",format=qcow2 \
      -drive if=virtio,file="$qemu_hdd_1",format=qcow2 \
      -boot order=a \
      -nic user,hostfwd=tcp::2222-:22,model=virtio-net-pci,mac=52:54:00:aa:bb:01 \
      -display vnc=:0
}

create_quemu_hdd "${qemu_hdd_0}"
create_quemu_hdd "${qemu_hdd_1}"
run_qemu
