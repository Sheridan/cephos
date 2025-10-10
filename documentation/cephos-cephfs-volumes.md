# cephos-cephfs-volumes

## Description
The `cephos-cephfs-volumes` script displays information about CephFS subvolume groups and their subvolumes. It provides a hierarchical view of all subvolume groups and their respective subvolumes with usage statistics.

## Functionality
1. Lists all subvolume groups in the CephFS filesystem
2. For each subvolume group, displays:
   - Group name
   - Total bytes used by the group
   - All subvolumes within the group with their paths and usage

## Output
- Displays the default `_nogroup` subvolume group
- Lists all named subvolume groups
- Shows subvolume paths and usage statistics for each subvolume

## Dependencies
- Requires working Ceph cluster configuration
- Requires existing CephFS filesystem

## Notes
- This is an informational script with no destructive actions
- It provides a quick overview of the CephFS storage structure
- Usage statistics help in capacity planning and monitoring
