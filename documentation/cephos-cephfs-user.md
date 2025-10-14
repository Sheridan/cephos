# cephos-cephfs-user

## Description
The `cephos-cephfs-user` script manages CephFS users and their permissions. It allows adding, deleting, and managing user access to CephFS subvolumes.

## Options
- `-a`: Add user or use existing user (default)
- `-d`: Delete user subvolume caps
- `-D`: Delete user
- `-u <name>`: User name (required)
- `-g <subvolume_group>`: CephFS subvolume group (default: `_nogroup`)
- `-s <subvolume>`: CephFS subvolume (required)
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
1. Validates required options (action, username)
1. Checks if the specified subvolume group and subvolume exist (for add/del actions)
1. Performs the specified action:
   - `add`: Adds or updates user caps for the specified subvolume
   - `del`: Deletes user caps and removes the user if no caps remain
   - `DEL`: Deletes the user completely from the cluster

## Validation
- Ensures username is specified and not "admin"
- Verifies subvolume group and subvolume existence for add/del actions
- Requires confirmation for user deletion

## Actions
- **Add**: Grants the user read/write access to the specified subvolume
- **Delete caps**: Removes the user's access to the specified subvolume
- **Delete user**: Completely removes the user from the Ceph cluster

## Dependencies
- Requires existing subvolume group and subvolume for add/del actions
- Requires working Ceph cluster configuration

## Notes
- The script does not create subvolumes; these must exist beforehand
- User deletion requires explicit confirmation
- The "admin" user cannot be managed with this script
