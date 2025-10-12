#!/bin/bash
set -e

SCRIPT_DIR="/usr/local/lib/live/config"

echo "[live-net-scripts] Waiting for network connectivity..."

if ! ping -c1 -W3 8.8.8.8 >/dev/null 2>&1
then
  echo "[live-net-scripts] Warning: Network target reached, but no Internet connectivity detected"
fi

echo "[live-net-scripts] Running scripts in $SCRIPT_DIR..."

if [ -d "$SCRIPT_DIR" ]
then
  for script in "$SCRIPT_DIR"/*
  do
    if [ -x "$script" ]
    then
      echo "[live-net-scripts] Executing $script..."
      "$script"
    else
      echo "[live-net-scripts] Skipping non-executable file $script"
    fi
  done
else
  echo "[live-net-scripts] Directory $SCRIPT_DIR not found"
fi

echo "[live-net-scripts] All scripts executed."
