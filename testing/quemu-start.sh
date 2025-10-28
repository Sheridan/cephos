#!/usr/bin/env bash

. live_build_config/includes.chroot_after_packages/usr/local/lib/cephos/base.sh.lib

read -r -d '' help_text <<EOF
  Usage: $0 -s <cluster_conf_string> [-m <memory>] [-d <disk_size>] [-c <cpus>] [-n <hdds>] [-r]
  Options:
    -s: VM cluster string
        String format: 'name:flash,flash2...;name1:flash3,flash4,flash5...' etc.
    -m: VM memory (e.g., 16G, 8192M)
        Default: 16G
    -d: VM disk size (e.g., 8G, 100G)
        Default: 8G
    -c: VM CPUs (e.g., 2, 4)
        Default: 2
    -n: VM HDDs (e.g., 2, 4)
        Default: 3
    -r: Force recreate VM disks
  Examples:
    $0 -s 'one:/dev/sdm,/dev/sdn;two:/dev/sdg,/dev/sdj'
    $0 -s 'one:/dev/sdm,/dev/sdn' -m 32G
    $0 -s 'one:/dev/sdm,/dev/sdn' -d 20G -c 4
    $0 -s 'one:/dev/sdm,/dev/sdn' -r
EOF

set -euo pipefail

# --- options parse ---
declare -A processes_pids=()

vm_disk_size="8G"
vm_memory="16G"
vm_cpus=2
vm_hdds=3

base_ssh_port=2200
base_http_port=8000
base_vnc_disp=10

cluster_conf_string=""
force_recreate=0
while getopts ":n:s:d:c:m:rhv" opt
do
  case ${opt} in
    s) cluster_conf_string="${OPTARG}" ;;
    m) vm_memory="${OPTARG}" ;;
    d) vm_disk_size="${OPTARG}" ;;
    c) vm_cpus="${OPTARG}" ;;
    n) vm_hdds="${OPTARG}" ;;
    r) force_recreate=1 ;;
    h) usage ;;
    v) verbose=1 ;;
   \?) wrong_opt "Unknown option -${OPTARG}" ;;
    :) wrong_opt "Option -${OPTARG} requires an argument" ;;
  esac
done

if [[ -z "$cluster_conf_string" ]]
then
  wrong_opt "-s option is required"
fi

# --- options parse ---

function create_qemu_hdd()
{
  local img="$1"
  if (( force_recreate ))
  then
    log_info "Removing existing $img..."
    rm -f "$img"
  fi

  if [[ ! -f "$img" ]]
  then
    log_info "Creating $img (${vm_disk_size})..."
    qemu-img create -f qcow2 "${img}" "${vm_disk_size}"
  else
    log_info "Using existing ${img} (${vm_disk_size})"
  fi
}

function run_vm()
{
  local vmname=$1; shift
  local disks=("$@")

  local vm_drives=()
  for rawdev in "${disks[@]}"
  do
    if [[ ! -b "${rawdev}" ]]
    then
      log_cry "${rawdev} is not a block device"
    fi
    vm_drives+=("-drive" "if=virtio,file=${rawdev},format=raw,cache=none")
  done

  for ((i=0; i<vm_hdds; i++))
  do
    local vhdd_file="tmp/${vmname}-hdd${i}.img"
    create_qemu_hdd "${vhdd_file}"
    vm_drives+=("-drive" "if=virtio,file=${vhdd_file},format=qcow2")
  done

  local idx=$((vm_index++))
  local vnc_disp=$((base_vnc_disp + idx))
  local ssh_port=$((base_ssh_port + idx))
  local http_port=$((base_http_port + idx))
  local pidfile
  local pid
  pidfile=$(mktemp -u)

  log_info "Starting VM ${vmname} (VNC :${vnc_disp}): cpus: ${vm_cpus}, mem: ${vm_memory}, disks: ${vm_disk_size}"
  qemu-system-x86_64 \
      -enable-kvm \
      -m ${vm_memory} \
      -smp ${vm_cpus} \
      "${vm_drives[@]}" \
      -boot order=a \
      -nic user,hostfwd=tcp::${ssh_port}-:22,hostfwd=tcp::${http_port}-:8080,model=virtio-net-pci \
      -nic vde,sock=tmp/vde1,model=virtio-net-pci \
      -nic vde,sock=tmp/vde2,model=virtio-net-pci \
      -display vnc=:${vnc_disp} \
      -name "${vmname}" \
      -daemonize \
      -pidfile "${pidfile}"
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]
  then
    pid=$(cat "${pidfile}")
    processes_pids[$pid]="vm: ${vmname}"
  else
    log_cry "Failed to start VM ${vmname} (exit code: ${exit_code})"
  fi
}

function run_vde_switch()
{
  local vde_path="$1"
  local pidfile
  local pid
  pidfile=$(mktemp -u)

  log_info "Starting switch ${vde_path}"
  vde_switch --hub -sock "${vde_path}" --daemon --pidfile "${pidfile}"
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]
  then
    pid=$(cat "${pidfile}")
    processes_pids[$pid]="vde: ${vde_path}"
  else
    log_cry "Failed to start vde_switch for ${vde_path} (exit code: ${exit_code})"
  fi
}

function parse_vm_conf()
{
  local vmdef="$1"
  local name="${vmdef%%:*}"
  local disks_str="${vmdef#*:}"
  IFS=',' read -ra disk_list <<< "${disks_str}"
  run_vm "$name" "${disk_list[@]}"
}

function cleanup()
{
  local exit_code=$?
  log_info "Script finished (exit code: ${exit_code}). Terminating processes..."
  local pid
  for pid in "${!processes_pids[@]}"
  do
    local description="${processes_pids[$pid]}"
    if kill -0 "$pid" 2>/dev/null
    then
      log_info "Stopping [${pid}] -> ${description}"
      kill "${pid}" 2>/dev/null || true
      sleep 0.5
      if kill -0 "${pid}" 2>/dev/null
      then
        log_wrn "[${pid}] (${description}) did not complete, sending SIGKILL"
        kill -9 "${pid}" 2>/dev/null || true
      fi
    else
      log_wrn "[${pid}] (${description}) no longer works"
    fi
  done
  echo "Cleanup completed."
}
trap cleanup EXIT
trap cleanup ERR
trap cleanup INT

# --- Main loop ---
mkdir -p tmp
run_vde_switch "tmp/vde1"
run_vde_switch "tmp/vde2"
sleep 1
vm_index=0
IFS=';' read -ra vms <<< "${cluster_conf_string}"
for vmdef in "${vms[@]}"
do
  parse_vm_conf "${vmdef}"
done

ask_confirmation "Running. Stop it?"
