# cephos-cephfs-user

## Description
The `cephos-cephfs-user` script manages CephFS users and their permissions for specified filesystems. It allows adding users or capabilities, deleting subvolume capabilities, and completely removing users from the cluster.

## Options
- `-a`: Add user or use existing user (default)
- `-d`: Delete user subvolume caps
- `-D`: Delete user
- `-u <name>`: User name (required)
- `-f <filesystem>`: CephFS name (default: `cephfs`)
- `-g <subvolume_group>`: CephFS subvolume group (default: `_nogroup`)
- `-s <subvolume>`: CephFS subvolume (required for `-a` and `-d`)
- `-h`: Display this help message
- `-v`: Enable verbose mode

## Examples
```bash
# Add user to a subvolume
cephos-cephfs-user -a -u myuser -g mygroup -s mysubvolume

# Delete user caps from a subvolume
cephos-cephfs-user -d -u myuser -g mygroup -s mysubvolume

# Delete user completely
cephos-cephfs-user -D -u myuser
```

## Functionality
1. Validates required options and CephFS configuration
1. For add and del actions: Checks if the specified subvolume group and subvolume exist
1. Performs the specified action:
   - `add`: Adds or updates user capabilities for the specified subvolume in the filesystem
   - `del`: Deletes user capabilities for the specified subvolume and removes the user if no capabilities remain
   - `DEL`: Deletes the user completely from the cluster

## Validation
- Ensures username is specified and not "admin"
- Verifies the specified CephFS filesystem exists
- Verifies subvolume group and subvolume existence for add/del actions
- Requires confirmation for user deletion

## Actions
- **Add** (`-a`): Grants the user read/write access to the specified subvolume (or updates existing capabilities)
- **Delete caps** (`-d`): Removes the user's access to the specified subvolume (and deletes the user if no other capabilities remain)
- **Delete user** (`-D`): Completely removes the user from the Ceph cluster

## Dependencies
- Requires an existing CephFS filesystem
- Requires existing subvolume group and subvolume for add/del actions
- Requires working Ceph cluster configuration

## Notes
- The script does not create subvolumes; these must exist beforehand
- User deletion requires explicit confirmation
- The "admin" user cannot be managed with this script
