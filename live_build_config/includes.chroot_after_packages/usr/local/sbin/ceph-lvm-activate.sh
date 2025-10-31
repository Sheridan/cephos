#!/usr/bin/env bash

. /usr/local/lib/cephos/base.sh.lib
verbose=1

set -euo pipefail

log_info "Scanning for LVM volume groups..."
vgscan --mknodes

log_info "Activating Ceph VGs..."
vgchange -ay

log_info "Activation done."
