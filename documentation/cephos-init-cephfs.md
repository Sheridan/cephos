# cephos-init-cephfs

## Description
The `cephos-init-cephfs` script initializes a Ceph File System (CephFS) on a Ceph cluster. It creates the necessary pools and configures the filesystem.

## Options
- `-h`: Display this help message
- `-v`: Enable verbose output

## Functionality
1. Creates CephFS metadata and data pools
1. Configures pool settings for optimal performance
1. Creates the CephFS filesystem
1. Sets filesystem configuration parameters
1. Initializes MDS (Metadata Server) service

## Pool Creation
- Creates `${cephfs_name}_metadata` pool with `bulk false` setting
- Creates `${cephfs_name}_data` pool with `bulk true` setting

## Filesystem Configuration
- Sets maximum MDS count to 1
- Configures standby count to 1
- Enables standby replay
- Disables refusal of standby for another filesystem

## MDS Initialization
- Calls `cephos-init-mds` to initialize MDS service
