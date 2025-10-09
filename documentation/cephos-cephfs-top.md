# cephos-cephfs-top

## Description
The `cephos-cephfs-top` script provides a real-time monitoring interface for CephFS (Ceph File System) performance metrics. It displays various statistics about the CephFS cluster, including client activity, cache usage, and more.

## Functionality
- Executes the `cephfs-top` command with the appropriate configuration
- Uses the main Ceph configuration file (`${ceph_main_conf}`)
- Connects to the Ceph cluster as the 'admin' user

## Usage
```bash
# Run cephfs-top
cephos-cephfs-top
```

## Configuration
- Connects to the Ceph cluster using the configuration in `${ceph_main_conf}`
- Uses the 'admin' user credentials for authentication

## Dependencies
- Depends on the Ceph cluster being running and accessible
