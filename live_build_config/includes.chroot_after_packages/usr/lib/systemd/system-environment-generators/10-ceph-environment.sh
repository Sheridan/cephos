#!/usr/bin/env bash

. /usr/local/lib/cephos/base.sh.lib
. /usr/local/lib/cephos/config.sh.lib
. /usr/local/lib/cephos/cephos.sh.lib

function apply_environment()
{
  echo "CLUSTER=ceph"
  echo "CEPH_CLUSTER=ceph"
  echo "CEPH_CONF='${ceph_main_conf}'"
}
