# cephos-conf-reconcile

## Description
The `cephos-conf-reconcile` script updates node configuration by synchronizing Ceph configuration files and host entries across the cluster nodes.

## Options
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Functionality
1. Updates the Ceph configuration file (`ceph.conf`) with current cluster information
1. Synchronizes host entries in `/etc/hosts` with the current cluster nodes

## Configuration Updates
- Adds monitor members and host IP addresses to `ceph.conf`
- Creates host records in `/etc/hosts` for both public and cluster IPs

## Usage
```bash
# Reconcile configuration with verbose output
cephos-conf-reconcile -v
```
