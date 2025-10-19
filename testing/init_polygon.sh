#!/bin/bash

. live_build_config/includes.chroot_after_packages/usr/local/lib/cephos/base.sh.lib
use_logfile=0

ssh_options="-o StrictHostKeyChecking=no"
max_wait_seconds=1800
check_interval=2

polygon_hosts=(cephos-mirzamon cephos-alpherat cephos-zubenelh)

declare -A polygon_private_ip_index
polygon_private_ip_index=(
    [cephos-mirzamon]="1"
    [cephos-alpherat]="2"
    [cephos-zubenelh]="3"
)

declare -A polygon_public_ip_index
polygon_public_ip_index=(
    [cephos-mirzamon]="24"
    [cephos-alpherat]="25"
    [cephos-zubenelh]="26"
)


declare -A polygon_disks
polygon_disks=(
    [cephos-mirzamon]="/dev/disk/by-id/ata-ST2000VX000-1CU164_W1E8FT7Q /dev/disk/by-id/ata-ST2000DM006-2DM164_Z4Z7J05N"
    [cephos-alpherat]="/dev/disk/by-id/ata-ST2000DM001-1CH164_W1E6JGT2 /dev/disk/by-id/ata-ST2000VX000-1CU164_Z1E2J076"
    [cephos-zubenelh]="/dev/disk/by-id/ata-ST2000DM001-1ER164_Z4Z3NC3E /dev/disk/by-id/ata-ST2000DM001-1CH164_W1E6HS6T"
)

function exec_ssh()
{
  local polygon_host="$1"
  local cmd="${@:2}"

  log_delimiter
  log_info "-------======| Executing on ${polygon_host}: ${cmd} |======-------"
  ssh ${ssh_options} -t cephos@${polygon_host} "${cmd}"
  log_delimiter
}

function wait_host()
{
  local polygon_host="$1"
  local start_time elapsed_time
  log_info "Waiting for SSH availability on host: ${polygon_host}"
  start_time=$(date +%s)
  while true
  do
    if ssh ${ssh_options} -o BatchMode=yes -o ConnectTimeout=16 cephos@${polygon_host} "echo ok" &>/dev/null
    then
      log_info "Host ${polygon_host} is available via SSH."
      break
    fi
    elapsed_time=$(( $(date +%s) - start_time ))
    if (( elapsed_time > max_wait_seconds ))
    then
      log_cry "Timeout waiting for SSH for host ${polygon_host} (${max_wait_seconds} sec)."
      return 1
    fi
    log_wrn "Host ${polygon_host} is unavailable. Retrying in ${check_interval} sec..."
    sleep "${check_interval}"
  done
}

function wait_all_hosts()
{
  for polygon_host in "${polygon_hosts[@]}"
  do
    wait_host "${polygon_host}" &
  done
  wait
}

function add_disks()
{
  local polygon_host="$1"
  for disk in ${polygon_disks[$polygon_host]}
  do
    log_info "Append disk ${disk}"
    exec_ssh "${polygon_host}" "echo 'y' | cephos-disk-add -v -d ${disk}"
  done
}

function init_first_node()
{
  local polygon_host="$1"
  exec_ssh "${polygon_host}" "cephos-add-timeserver -v -s 10.0.0.1 -p ru.pool.ntp.org"
  exec_ssh "${polygon_host}" "cephos-init-cluster -v"
  add_disks "${polygon_host}"
  exec_ssh "${polygon_host}" "cephos-init-cephfs -v"
  exec_ssh "${polygon_host}" "cephos-init-metrics -v"
}

function init_next_node()
{
  local polygon_host="$1"
  local ip_index="${polygon_public_ip_index[$polygon_host]}"
  local parent_ip_index=$(( ip_index - 1 ))
  exec_ssh "${polygon_host}" "cephos-connect-to-cluster -v -n 10.0.1.${parent_ip_index}"
  add_disks "${polygon_host}"
  exec_ssh "${polygon_host}" "cephos-init-mds -v"
  exec_ssh "${polygon_host}" "cephos-init-metrics -v"
}

log_info "Initializing networks..."
for polygon_host in "${polygon_hosts[@]}"
do
  ssh-keygen -R "${polygon_host}"
  sshpass -p 'cephos' ssh-copy-id ${ssh_options} cephos@${polygon_host} &>/dev/null
  exec_ssh "${polygon_host}" "echo 'n' | cephos-setup-interface -i enp2s0 -d -n public_0"
  exec_ssh "${polygon_host}" "echo 'y' | cephos-setup-interface -i enp1s0 -m 255.255.255.0 -a 172.16.16.${polygon_private_ip_index[$polygon_host]} -n ceph_0"
done

log_info "Waiting for hosts reboot..."
sleep 10
wait_all_hosts

log_info "Initializing hosts..."
for polygon_host in "${polygon_hosts[@]}"
do
  exec_ssh "${polygon_host}" "echo 'y' | cephos-force-timesync -v -s 10.0.0.1"
  exec_ssh "${polygon_host}" "cephos-init-host -v -n ${polygon_host}.sheridan-home.local -z 'Europe/Moscow' -P 10.0.0.0/8 -C 172.16.16.0/24 -p 10.0.1.${polygon_public_ip_index[$polygon_host]} -c 172.16.16.${polygon_private_ip_index[$polygon_host]}"
done

log_info "Initializing cephos..."
for polygon_host in "${polygon_hosts[@]}"
do
  if [[ "${polygon_host}" == "${polygon_hosts[0]}" ]]
  then
    init_first_node "${polygon_host}"
  else
    init_next_node "${polygon_host}"
  fi
done

exec_ssh "${polygon_hosts[0]}" "cephos-conf-sync -v"
exec_ssh "${polygon_hosts[0]}" "cephos-cephfs-compression -v -a lz4 -m aggressive -r 0.9"
exec_ssh "${polygon_hosts[0]}" "ceph dashboard set-prometheus-api-host http://prometheus.sheridan-home.local"
