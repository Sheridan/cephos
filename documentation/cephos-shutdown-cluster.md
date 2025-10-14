# cephos-shutdown-cluster

## Description

The `cephos-shutdown-cluster` script is used to gracefully shut down an entire Ceph cluster. It handles the proper shutdown sequence by first shutting down all other nodes in the cluster and then shutting down the local node.

## Usage

```bash
cephos-shutdown-cluster [-hv]
```

## Options

- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Description

The script performs the following operations:

1. Shuts down all other nodes in the cluster by executing `sudo poweroff` on each node
1. Shuts down the local node by executing `sudo poweroff`
