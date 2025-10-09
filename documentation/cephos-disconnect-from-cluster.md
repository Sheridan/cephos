# cephos-disconnect-from-cluster

## Description
The `cephos-disconnect-from-cluster` script removes a node from a Ceph cluster. It safely removes all local disks, stops Ceph services, and cleans up configuration files.

## Options
- `-h`: Display this help message
- `-v`: Enable verbose output

## Functionality
1. Prompts for confirmation before proceeding
1. Removes all local OSDs (Object Storage Daemons) from the cluster
1. Stops and removes MDS (Metadata Server) service
1. Stops and removes MGR (Manager) service
1. Stops and removes MON (Monitor) service
1. Stops and disables all Ceph services
1. Removes Ceph data directories
1. Disables monitoring services

## Disk Removal
- Uses `cephos-disk-remove` to safely remove each OSD
- Marks OSDs as out before removal
- Purges OSD data from the cluster

## Service Cleanup
- Stops and disables Ceph services (MON, MGR, MDS)
- Removes Ceph configuration and data directories
- Disables monitoring services (Prometheus, Telegraf, etc.)
