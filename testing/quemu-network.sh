#!/usr/bin/env bash

qemu_bridge_interface="br_qemu"
qemu_tap_interfaces_prefix="tap_qemu"
qemu_bridge_mac="02:11:00:22:44:01"

function usage()
{
    cat <<EOF
Options:
  -m: work mode (up|down)
  -i: host master network interface
Examples:
  Network up:
    $0 -m up -i eth0
  Network down:
    $0 -m down
EOF
}

work_mode=""
host_master_interface=""
while getopts ":m:i:h" opt
do
  case ${opt} in
    h) usage; exit 0 ;;
    i) host_master_interface="${OPTARG}" ;;
    m) work_mode="${OPTARG}" ;;
   \?) echo "Ошибка: неизвестная опция -${OPTARG}"; exit 1 ;;
    :) echo "Ошибка: опция -${OPTARG} требует аргумент"; exit 1 ;;
  esac
done

if [[ -z "$host_master_interface" ]]
then
  echo "Нужно указать host master network interface"
  usage
  exit 1
fi

if [[ -z "$work_mode" ]]
then
  echo "Нужно указать work mode"
  usage
  exit 1
fi

function is_up()
{
  [[ "$work_mode" == "up" ]]
}

function request_ip()
{
  local interface="${1}"
  dhcpcd -n ${interface} || dhclient -v ${qemu_bridge_inteinterfacerface}
}

function network_up()
{
  echo "Поднимаю мост ${qemu_bridge_interface}..."
  ip link add name ${qemu_bridge_interface} type bridge
  ip link set dev ${qemu_bridge_interface} address "${qemu_bridge_mac}"
  ip addr flush dev ${host_master_interface}
  ip link set ${host_master_interface} master ${qemu_bridge_interface}
  ip link set ${host_master_interface} up
  ip link set ${qemu_bridge_interface} up
  request_ip ${qemu_bridge_interface}
}

function delete_tap_interfaces()
{
  echo ">>> Удаляю TAP-интерфейсы с префиксом ${qemu_tap_interfaces_prefix}..."
  for t in $(ip -o link show | awk -F': ' '{print $2}' | grep -E "^${qemu_tap_interfaces_prefix}")
  do
    echo "  - удаляю ${t}"
    ip link del ${t} || true
  done
}

function network_down()
{
  echo ">>> Опускаю мост ${qemu_bridge_interface}..."
  ip link set ${host_master_interface} nomaster
  ip addr flush dev ${qemu_bridge_interface}
  delete_tap_interfaces
  ip link set ${qemu_bridge_interface} down
  ip link delete ${qemu_bridge_interface} type bridge
  request_ip ${host_master_interface}
}

if is_up
then
  network_up
else
  network_down
fi
