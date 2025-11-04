#!/usr/bin/env bash

. /usr/local/lib/cephos/cephos.sh.lib
use_logfile=0

function apply_environment()
{
  echo "CLUSTER=ceph"
  echo "CEPH_CLUSTER=ceph"
  echo "CEPH_CONF='${ceph_main_conf}'"
}

apply_environment
