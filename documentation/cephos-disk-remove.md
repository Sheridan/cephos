# cephos-disk-remove

## Description
The `cephos-disk-remove` script removes a block device (OSD) from a Ceph cluster. It safely removes the OSD and purges all data from the device.

## Options
- `-d <block_device>`: Specify the block device to remove (e.g., `/dev/sdb`)
- `-h`: Show this help message
- `-v`: Enable verbose output

## Examples
```bash
# Remove /dev/sdb from the cluster
cephos-disk-remove -d /dev/sdb
```

## Functionality
1. Validates that a block device is specified
1. Checks if the block device exists and is valid
1. Verifies that the block device is in use by Ceph
1. Prompts for confirmation before proceeding
1. Marks the OSD as out in the cluster
1. Stops the OSD service
1. Removes the OSD from the cluster
1. Zaps the device to remove all Ceph data
1. Purges the device

## OSD Removal Process
- Gets the OSD ID associated with the block device
- Marks the OSD as out in the cluster
- Stops the OSD service
- Removes the OSD from the CRUSH map
- Deletes OSD authentication keys
- Removes the OSD from the cluster
- Zaps the device to remove all Ceph data
- Purges the device
