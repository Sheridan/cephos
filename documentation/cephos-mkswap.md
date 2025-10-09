# cephos-mkswap

## Description
The `cephos-mkswap` script creates a swap space on a specified block device. It formats the device, updates `/etc/fstab`, and enables the swap.

## Options
- `-d <block_device>`: Specify the block device to use for swap
- `-h`: Display this help message
- `-v`: Enable verbose output

## Example
```bash
# Create swap on /dev/sdb
cephos-mkswap -d /dev/sdb
```

## Functionality
1. Validates that a block device is specified
1. Checks if the block device exists and is valid
1. Prompts for confirmation before proceeding
1. Formats the block device as swap
1. Updates `/etc/fstab` with the swap entry
1. Enables the swap space

## Swap Creation
- Uses `mkswap` to format the block device
- Gets the UUID of the formatted swap device
- Adds the swap entry to `/etc/fstab`
- Enables the swap space with `swapon`

## Dependencies
- Depends on proper block device availability
