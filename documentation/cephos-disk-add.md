# cephos-disk-add

## Description
The `cephos-disk-add` script adds a new block device to a Ceph cluster by creating a new OSD (Object Storage Daemon).

## Options
- `-d <block_device>`: Specify the block device to append (e.g., `/dev/sdb`)
- `-h`: Show this help message
- `-v`: Enable verbose output

## Examples
```bash
# Add /dev/sdb to the cluster
cephos-disk-add -d /dev/sdb

# Add /dev/sdc with verbose output
cephos-disk-add -d /dev/sdc -v
```

## Functionality
1. Validates that a block device is specified
1. Checks if the block device exists and is valid
1. Verifies that the block device is not already in use by Ceph
1. Prompts for confirmation before proceeding
1. Purges the block device
1. Creates a new OSD using ceph-volume
1. Sets appropriate file system permissions

## Device Validation
- Checks if the block device exists
- Verifies that the device is not already in use by Ceph
- Confirms with the user before proceeding

## OSD Creation
- Uses `ceph-volume lvm create` to create the OSD
- Configures the OSD with bluestore object store
- Sets file system permissions for the OSD
