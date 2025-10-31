# cephos-cephfs-subvolume

## Description

The `cephos-cephfs-subvolume` script manages CephFS subvolumes and subvolume groups in a Ceph cluster. It supports creating (adding) and removing (deleting) subvolumes, with automatic handling of subvolume groups: groups are created if they do not exist when adding a subvolume, and deleted if they become empty after deletion.

## Usage

```
cephos-cephfs-subvolume <-a|-d> -g subvolume_group -s subvolume [-hv]
```

CephFS subvolumes and subvolume groups management.

### Options

- `-a`: Add subvolume (default action).
- `-d`: Delete subvolume (and removes the group if it becomes empty).
- `-g <subvolume_group>`: Specify the subvolume group name (default: `${cephfs_nogroup}`, typically no group).
- `-s <subvolume>`: Specify the subvolume name (required).
- `-h`: Show this help message and exit.
- `-v`: Enable verbose mode for detailed logging.

## Examples

### Adding a Subvolume to a Group

Create a subvolume named `data` in the group `users` (the group will be created if it does not exist):

```
cephos-cephfs-subvolume -a -g users -s data
```

### Adding a Subvolume without a Group

Create a subvolume named `temp` without assigning it to a group:

```
cephos-cephfs-subvolume -a -s temp
```

### Deleting a Subvolume

Remove the subvolume `data` from the group `users` (the group will be deleted if empty):

```
cephos-cephfs-subvolume -d -g users -s data
```

## Behavior Details

- **Adding a Subvolume**:
  - If the subvolume does not exist in the specified group, it is created using default `_nogroup` group.
  - The subvolume group is created if it does not exist and a group is specified (using `ceph fs subvolumegroup create`).
  - If the subvolume already exists, a verbose message is logged, but no action is taken.

- **Deleting a Subvolume**:
  - If the subvolume exists, it is removed using `ceph fs subvolume rm`.
  - After deletion, if the group is empty (no remaining subvolumes), the group is automatically deleted using `ceph fs subvolumegroup rm`.
  - If the subvolume does not exist, a verbose message is logged.

## Prerequisites

- A configured Ceph cluster with CephFS filesystem.

## Related Commands

- [cephos-cephfs-volumes](cephos-cephfs-volumes.md): List or manage CephFS volumes.
- [cephos-init-cephfs](cephos-init-cephfs.md): Initialize CephFS.
- Ceph CLI: `ceph fs subvolume ls`, `ceph fs subvolumegroup ls` for inspection.
