# cephos-connect-to-cluster

## Description
The `cephos-connect-to-cluster` script connects a node to an existing Ceph cluster. It copies necessary configuration files and keys from a working cluster node to the new node.

## Options
- `-n <cluster_node_ip>`: Specify any working cluster node IP address
- `-h`: Display this help message
- `-v`: Enable verbose output

## Examples
```bash
# Connect to cluster using a working node
cephos-connect-to-cluster -n 10.10.0.100
```

## Functionality
1. Validates that a cluster node IP is specified
1. Generates SSH keys for the current user
1. Copies configuration files from the specified cluster node:
   - Cluster configuration (`cluster.ini`)
   - Ceph configuration (`ceph.conf`)
   - Ceph client admin keyring
   - OSD bootstrap keyring
1. Sets up chrony time synchronization
1. Initializes monitor and manager services

## Configuration Files Copied
- `/etc/ceph/cluster.ini`
- `/etc/ceph/ceph.conf`
- `/etc/ceph/ceph.client.admin.keyring`
- `/var/lib/ceph/bootstrap-osd/ceph.keyring`

## Services Initialized
- Ceph monitor service
- Ceph manager service
- Chrony time synchronization

## Dependencies
- Depends on working network connectivity between nodes
