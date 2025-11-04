# cephos-cephfs-manager

## Description

The `cephos-cephfs-manager` script manages Ceph File Systems (CephFS) in a CephOS cluster. It allows adding a new CephFS instance or deleting an existing one, including handling associated pools and configurations.

## Options

- `-a`              Add CephFS instance
- `-d`              Delete CephFS instance
- `-f <filesystem>` CephFS name (default 'storage')
- `-h`              Display this help message
- `-v`              Enable verbose output

## Usage Examples

### Adding a CephFS

To add a CephFS named 'myfs':

```bash
cephos-cephfs-manager -a -f myfs -v
```

This creates the CephFS with pools, applies default configurations, sets permissions, and initializes the MDS manager on all cluster nodes.

### Deleting a CephFS

To delete a CephFS named 'myfs':

```bash
cephos-cephfs-manager -d -f myfs
```

This removes the filesystem and deletes the associated metadata and data pools.

## Prerequisites

- A running and initialized Ceph cluster.
- Administrative privileges for Ceph operations.
- SSH access configured for cluster nodes if managing multiple hosts.
