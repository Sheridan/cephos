# cephos-init-mon

## Description
The `cephos-init-mon` script initializes a Ceph Monitor (MON) service on a node. It creates the necessary directories and configuration for the monitor service.

## Options
- `-n`: Cluster node when connecting to cluster (internal use)
- `-h`: Display this help message
- `-v`: Enable verbose output

## Functionality
1. Checks if MON already exists on the host
1. If MON doesn't exist:
   - Creates MON data directory
   - Generates authentication keys
   - Creates monitor map
   - Initializes monitor service

## MON Initialization
- Creates directory structure for MON data
- Generates authentication keys for MON
- Creates monitor map (either new or from existing cluster)
- Initializes the monitor service

## Cluster Connection
- Can connect to an existing cluster using an existing node
- Copies monitor key and map from existing cluster node
