#!/bin/bash
# run-ceph-vm.sh
# Запуск QEMU для теста Ceph c загрузкой с USB‑флешки и двумя HDD

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Использование: $0 /dev/sdX"
    exit 1
fi

FLASH_DEV="$1"

# Проверим, что устройство существует
if [[ ! -b "$FLASH_DEV" ]]; then
    echo "Ошибка: $FLASH_DEV не найдено или не является блочным устройством"
    exit 1
fi

# Имена файлов для виртуальных HDD
DISK1="tmp/ceph-hdd1.img"
DISK2="tmp/ceph-hdd2.img"

# Если образы ещё не созданы – создаём по 1G каждый
if [[ ! -f "$DISK1" ]]; then
    echo "Создаю $DISK1 (1G)..."
    qemu-img create -f raw "$DISK1" 1G
fi

if [[ ! -f "$DISK2" ]]; then
    echo "Создаю $DISK2 (1G)..."
    qemu-img create -f raw "$DISK2" 1G
fi

# Запуск QEMU
echo "Запуск QEMU (флешка: $FLASH_DEV)"
qemu-system-x86_64 \
    -enable-kvm \
    -m 8192 \
    -smp 2 \
    -drive if=virtio,file="$FLASH_DEV",format=raw,cache=none \
    -drive if=virtio,file="$DISK1",format=raw \
    -drive if=virtio,file="$DISK2",format=raw \
    -boot order=a \
    -display vnc=:0
