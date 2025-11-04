# cephos-cephfs-replica

The `cephos-cephfs-replica` script configures the replication size for a CephFS filesystem. It sets the target replication size and minimum replication size for both the data and metadata pools associated with the specified CephFS.

## Prerequisites

- A running Ceph cluster.
- The target CephFS must already exist.

## Usage

```
cephos-cephfs-replica -f <cephfs_name> -S <size> [-s <min_size>] [-v]
```

### Options

- `-f <cephfs_name>`: Specifies the name of the CephFS filesystem. Defaults to the value of `storage` if not provided.
- `-S <size>`: Sets the target replication size for the pools. Must be at least 2.
- `-s <min_size>`: Sets the minimum replication size for the pools. Defaults to `size - 1` if not provided, but must be at least 1 and less than `size`.
- `-h`: Displays the help message and exits.
- `-v`: Enables verbose logging.

### Validation

The script performs the following checks:
- The replication size (`-S`) must be greater than or equal to 2.
- The minimum replication size (`-s`) must be greater than or equal to 1 and less than the replication size.
- The specified CephFS must exist in the cluster.

If any validation fails, the script exits with an error message.

## Examples

### Set replication for the default CephFS

To configure a replication size of 3 (with minimum size automatically set to 2) for the default CephFS:

```
cephos-cephfs-replica -S 3
```

### Set custom replication for a specific CephFS

To set a replication size of 3 and minimum size of 2 for a CephFS named `mycephfs`:

```
cephos-cephfs-replica -f mycephfs -S 3 -s 2
```

## Notes

- This script modifies the `size` and `min_size` properties of the `<cephfs_name>_data` and `<cephfs_name>_metadata` pools.
- Changes take effect immediately but may require time for the cluster to rebalance data across OSDs.
- Use this script after initial CephFS creation or when adjusting redundancy levels in response to cluster changes.
