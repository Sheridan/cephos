# cephos-conf-sync

## Description
The `cephos-conf-sync` script synchronizes configurations across all cluster nodes. It ensures that each node in the Ceph cluster has consistent configuration files and settings.

## Options
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Functionality
1. Generates SSH keys for the current user if they don't exist
2. Synchronizes configuration across all cluster nodes by:
   - Executing `cephos-conf-reconcile` on each node
   - Using SSH to connect to remote nodes
   - Distributing SSH keys as needed

## Usage
```bash
# Synchronize configurations across the cluster
cephos-conf-sync

# Synchronize with verbose output
cephos-conf-sync -v
```

## Configuration Synchronization
- Calls `cephos-conf-reconcile` on the local node
- Uses SSH to execute `cephos-conf-reconcile` on remote nodes
- Distributes SSH keys to remote nodes for authentication

## Dependencies
- Depends on the `cephos-conf-reconcile` script for individual node configuration
