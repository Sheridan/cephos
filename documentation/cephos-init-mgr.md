# cephos-init-mgr

## Description
The `cephos-init-mgr` script initializes a Ceph Manager (MGR) service on a node. It creates the necessary directories and configuration for the manager service.

## Options
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Functionality
1. Checks if MGR already exists on the host
1. If MGR doesn't exist:
   - Creates MGR data directory
   - Generates MGR authentication keys
   - Sets file system permissions
   - Enables MGR service
   - Configures dashboard and stats modules
   - Creates default dashboard user

## MGR Initialization
- Creates directory structure for MGR data
- Generates authentication keys for MGR
- Configures service permissions
- Enables the MGR service

## Dashboard Configuration
- Enables dashboard module
- Enables stats module
- Configures dashboard settings (port 8080, no SSL)
- Creates default user with password 'P@ssw0rd'
