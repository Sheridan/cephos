# cephos-init-cluster

## Description
The `cephos-init-cluster` script initializes a new Ceph cluster. It sets up the basic cluster configuration and initializes monitor and manager services.

## Options
- `-h`: Display this help message
- `-v`: Enable verbose output

## Functionality
1. Generates a new cluster FSID (UUID)
1. Creates cluster environment variables
1. Configures Ceph monitor settings
1. Sets cluster network and public network parameters
1. Configures OSD pool settings
1. Creates authentication keys
1. Initializes monitor and manager services

## Cluster Configuration
- Sets `mon_initial_members` to the current hostname
- Configures monitor host IP address
- Sets cluster FSID
- Configures network settings (cluster and public)
- Sets security settings (cephx authentication)

## Key Creation
- Creates monitor keyring
- Imports admin and bootstrap OSD keyrings
- Creates monitor map

## Service Initialization
- Calls `cephos-init-mon` to initialize monitor service
- Calls `cephos-init-mgr` to initialize manager service

## Dependencies
- Depends on `cephos-init-mon` and `cephos-init-mgr` for service initialization
