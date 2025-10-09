# cephos-init-mds

## Description
The `cephos-init-mds` script initializes a Ceph Metadata Server (MDS) on a node. It creates the necessary directories and configuration for the MDS service.

## Options
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Functionality
1. Checks if MDS already exists on the host
1. If MDS doesn't exist:
   - Creates MDS data directory
   - Generates MDS authentication keys
   - Sets file system permissions
   - Enables MDS service

## MDS Initialization
- Creates directory structure for MDS data
- Generates authentication keys for MDS
- Configures service permissions
- Enables the MDS service

## Service Management
- Uses `ceph-authtool` to create MDS keyring
- Enables the `ceph-mds@${mds_id}` service

## Dependencies
- Depends on proper Ceph cluster configuration
