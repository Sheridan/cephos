#!/bin/bash

. live_build_config/includes.chroot_after_packages/usr/local/lib/cephos/base.sh.lib

ssh_options="-o StrictHostKeyChecking=no"
max_vm_wait_seconds=300
check_interval=2

vm_hosts=(cf cs ct)

declare -A vm_ssh_ports
declare -A vm_ip_index

vm_ssh_ports=(
    [cf]="2200"
    [cs]="2201"
    [ct]="2202"
)

vm_ip_index=(
    [cf]="10"
    [cs]="11"
    [ct]="12"
)

function exec_ssh()
{
  local vm="$1"; shift
  local cmd="$@"
  local vm_ssh_port="${vm_ssh_ports[$vm]}"

  log_delimiter
  log_info "-------======| Executing on ${vm}: ${cmd} |======-------"
  ssh ${ssh_options} -t -p ${vm_ssh_port} cephos@127.0.0.1 "${cmd}"
  log_delimiter
}

function wait_vm()
{
  local vm="$1"
  local start_time elapsed_time
  log_info "Waiting for SSH availability on vm: $vm"
  start_time=$(date +%s)
  while true
  do
    if ssh ${ssh_options} -o BatchMode=yes -o ConnectTimeout=3 -p ${vm_ssh_ports[$vm]} cephos@127.0.0.1 "echo ok" &>/dev/null
    then
      log_info "VM $vm is available via SSH."
      break
    fi
    elapsed_time=$(( $(date +%s) - start_time ))
    if (( elapsed_time > max_vm_wait_seconds ))
    then
      log_cry "Timeout waiting for SSH for VM $vm (${max_vm_wait_seconds} sec)."
      return 1
    fi
    log_wrn "VM $vm is unavailable. Retrying in ${check_interval} sec..."
    sleep "$check_interval"
  done
}

function wait_all_vm()
{
  for vm in "${vm_hosts[@]}"
  do
    wait_vm "${vm}" &
  done
  wait
}

function inti_first_node()
{
  local vm="$1"
  exec_ssh "${vm}" "cephos-add-timeserver -v -s 10.0.0.1 -p ru.pool.ntp.org"
  exec_ssh "${vm}" "cephos-init-cluster -v"
  exec_ssh "${vm}" "echo 'y' | cephos-append-disk -v -d /dev/vdb"
  exec_ssh "${vm}" "echo 'y' | cephos-append-disk -v -d /dev/vdc"
  exec_ssh "${vm}" "cephos-init-cephfs -v"
  exec_ssh "${vm}" "cephos-init-metrics -v"
}

function init_next_node()
{
  local vm="$1"
  local ip_index="${vm_ip_index[$vm]}"
  local parent_ip_index=$(( ip_index - 1 ))
  exec_ssh "${vm}" "cephos-connect-to-cluster -v -n 192.168.0.${parent_ip_index}"
  exec_ssh "${vm}" "echo 'y' | cephos-append-disk -v -d /dev/vdb"
  exec_ssh "${vm}" "echo 'y' | cephos-append-disk -v -d /dev/vdc"
  exec_ssh "${vm}" "cephos-init-mds -v"
  exec_ssh "${vm}" "cephos-init-metrics -v"
}

# function test()
# {
#   local vm="$1"
#   local ip_index="${vm_ip_index[$vm]}"
#   local parent_ip_index=$(( ip_index - 1 ))
#   echo "${vm} - ${ip_index} - ${parent_ip_index}"
#   exit 0
# }

# test "ct"

log_info "Initializing networks..."
for vm in "${vm_hosts[@]}"
do
  ssh-keygen -R "[127.0.0.1]:${vm_ssh_ports[$vm]}"
  sshpass -p 'cephos' ssh-copy-id ${ssh_options} -p ${vm_ssh_ports[$vm]} cephos@127.0.0.1 &>/dev/null
  exec_ssh "${vm}" "echo 'n' | cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.${vm_ip_index[$vm]} -n public_0"
  exec_ssh "${vm}" "echo 'y' | cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.${vm_ip_index[$vm]} -n ceph_0"
done

log_info "Waiting..."
sleep 10
wait_all_vm

log_info "Initializing hosts..."
for vm in "${vm_hosts[@]}"
do
  exec_ssh "${vm}" "cephos-init-host -v -n ${vm}.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.${vm_ip_index[$vm]} -c 192.168.1.${vm_ip_index[$vm]}"
done

log_info "Initializing cephos..."
for vm in "${vm_hosts[@]}"
do
  if [[ "${vm}" == "${vm_hosts[0]}" ]]
  then
    inti_first_node "${vm}"
  else
    init_next_node "${vm}"
  fi
done
