# cephos-cephfs-volumes

## Description

The `cephos-cephfs-volumes` script displays detailed information about all CephFS filesystems in the cluster, including replication configurations for data and metadata pools, subvolume groups, and individual subvolumes with their usage statistics. It offers a hierarchical view to help monitor and manage CephFS storage.

## Usage

Execute the script without any arguments to generate the report:

```bash
cephos-cephfs-volumes
```

The script outputs directly to stdout in a formatted, human-readable structure.

## Output Format

The output is organized by filesystem and includes:

- **Filesystem Name**: The name of each CephFS filesystem (e.g., "cephfs").

- **Replicas**:
  - Data pool replication: Full size and minimum size (e.g., "3 with minimum 2").
  - Metadata pool replication: Full size and minimum size (e.g., "3 with minimum 2").

- **Volumes**:
  - Default group (typically `_nogroup`): Lists all subvolumes directly under this group.
  - Named subvolume groups: For each group, shows the group name and total bytes used, followed by its subvolumes.

- **Subvolume Details** (for each subvolume in groups):
  - Subvolume name.
  - Mount path within the filesystem.
  - Bytes used by the subvolume.

## Prerequisites

- A functional Ceph cluster with at least one CephFS filesystem created and active.

## Notes

- This is a non-interactive, read-only script that performs no modifications to the cluster.
- It aggregates data from multiple CephFS filesystems if present in the cluster.
- Ideal for routine checks, troubleshooting storage issues, or generating reports for capacity planning.
