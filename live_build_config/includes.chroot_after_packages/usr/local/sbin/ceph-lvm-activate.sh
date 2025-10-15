#!/bin/bash
set -euo pipefail

echo "[ceph-lvm] Scanning for LVM volume groups..."
vgscan --mknodes

echo "[ceph-lvm] Activating Ceph VGs..."
vgchange -ay

echo "[ceph-lvm] Activation done."
