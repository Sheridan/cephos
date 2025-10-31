#!/usr/bin/env bash

. /usr/local/lib/cephos/base.sh.lib
verbose=1

set -e

scripts_directory="/usr/local/lib/live/net-online"

function is_online()
{
  local addresses=("8.8.8.8" "1.1.1.1" "8.8.4.4")

  for addr in "${addresses[@]}"
  do
    if ping -c1 -W3 "${addr}" >/dev/null 2>&1
    then
      return 0
    fi
  done
  return 1
}

function wait_for_online()
{
  local max_retries=30
  local retry=0

  log_info "Waiting for Internet connectivity..."

  while (( retry < max_retries ))
  do
    if is_online
    then
      log_info "Internet connectivity established."
      return 0
    fi
    ((retry++))
    sleep 2
  done

  log_err "Timeout reached — no internet connectivity after $((max_retries*2)) seconds."
  return 1
}

if [[ -d "${scripts_directory}" ]]
then

  if ! wait_for_online
  then
    log_cry "No internet connectivity detected. Terminating."
  fi

  log_info "Running scripts in ${scripts_directory}..."

  for script in "${scripts_directory}"/*
  do
    if [[ -x "${script}" ]]
    then
      log_info "Executing ${script}"
      "$script"
    else
      log_warn "Skipping non-executable file ${script}"
    fi
  done

else
  log_err "Directory ${scripts_directory} not found"
fi

log_info "All scripts executed."
