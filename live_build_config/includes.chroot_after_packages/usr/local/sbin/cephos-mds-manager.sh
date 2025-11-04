#!/usr/bin/env bash

. /usr/local/lib/cephos/mds.sh.lib
. /usr/local/lib/cephos/ssh.sh.lib
. /usr/local/lib/cephos/systemd.sh.lib
. /usr/local/lib/cephos/cephos.sh.lib

# set -euo pipefail

max_sleep_delay=30

function random_sleep()
{
  local half_sleep=$(( max_sleep_delay / 2 ))
  local delay=$(( RANDOM % half_sleep + half_sleep ))
  log_info "Sleeping ${delay} seconds"
  sleep "${delay}"
}

function start_new_mds()
{
  local idx=0
  local mds_id=""
  local mds_data_path mds_key
  while true
  do
    mds_id="$(make_mds_id "${idx}")"

    if ! systemd_service_started "ceph-mds@${mds_id}"
    then
      start_mds "${mds_id}"
      break
    else
      log_info "MDS ${mds_id} already started"
    fi
    idx=$((idx + 1))
  done
}

function stop_one_mds()
{
  local idx=0
  local mds_id=""
  local mds_data_path
  while true
  do
    mds_id="$(make_mds_id "${idx}")"
    mds_data_path="$(make_mds_data_path "${mds_id}")"

    if [[ ! -d "$mds_data_path" ]]
    then
      log_wrn "No more MDS ${mds_id}"
      break
    fi

    if systemd_service_started "ceph-mds@${mds_id}"
    then
      stop_mds "${idx}"
      break
    else
      log_info "MDS ${mds_id} already stopped"
    fi
    idx=$((idx + 1))
  done
}

function stop_all_mds()
{
  local idx=0
  local mds_id=""
  local mds_data_path
  log_info "Stopping and cleaning all local MDS"
  while true
  do
    mds_id="$(make_mds_id "${idx}")"
    mds_data_path="$(make_mds_data_path "${mds_id}")"
    if [[ ! -d "$mds_data_path" ]]
    then
      log_wrn "No more MDS ${mds_id}"
      break
    fi
    stop_mds "${idx}"
    idx=$((idx + 1))
  done
}

function main_loop()
{
  stop_all_mds

  log_info "MDS manager main loop starting"
  local fs_count max_mds active_mds local_active
  while true
  do
    fs_count=$(get_fs_count)
    [[ -z "$fs_count" ]] && fs_count=0
    local_active=$(get_local_active_count)
    if (( fs_count > 0 ))
    then
      max_sleep_delay=30
      max_mds=$(( (fs_count * 2) + 1 ))
      max_local_mds=$(( fs_count  + 1 ))
      active_mds=$(get_active_mds_count)
      log_info "Filesystems count: ${fs_count}, max MDS: ${max_mds}, active MDS: ${active_mds}, local active MDS: ${local_active}, max local active MDS: ${max_local_mds}"
      if (( local_active < max_local_mds ))
      then
        if (( active_mds < max_mds ))
        then
            log_info "Not enough MDS (${active_mds} < ${max_mds}). Starting one"
            start_new_mds
        elif (( active_mds > max_mds ))
        then
            log_info "Too many MDS (${active_mds} > ${max_mds}). Stopping one"
            stop_one_mds
        else
            log_info "Number of MDS matches the required"
            max_sleep_delay=60
        fi
      else
        log_info "Too many local MDS (${local_active} > ${max_local_mds}). Stopping one"
        stop_one_mds
      fi
    else
      if (( local_active > 0 ))
      then
        log_info "No filesystems configured. Stopping MDS"
        stop_one_mds
      else
        log_info "No filesystems configured and no active MDS. Stopping self"
        manage_systemd_service_state "disable" "cephos-mds-manager"
        exit 0
      fi
    fi
    random_sleep
  done
}

main_loop
