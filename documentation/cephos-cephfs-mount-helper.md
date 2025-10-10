# cephos-cephfs-mount-helper

## Description
The `cephos-cephfs-mount-helper` script is a CephFS mount helper that prepares and packages the necessary configuration files for mounting a CephFS subvolume on a client host. It generates mount scripts, fstab entries, and systemd unit files for automating the mount process.

## Options
- `-u <name>`: User name (required)
- `-g <subvolume_group>`: CephFS subvolume group (default: `_nogroup`)
- `-s <subvolume>`: CephFS subvolume (required)
- `-p <mountpoint>`: Client host mountpoint (required)
- `-o <arch_name>`: Tar archive name (required)
- `-h`: Display this help message
- `-v`: Enable verbose mode

## Examples
```bash
# Create mount configuration for a user
cephos-cephfs-mount-helper -u myuser -g mygroup -s mysubvolume -p /mnt/cephfs -o cephfs-mount-config.tar.gz
```

## Functionality
1. Validates required options (username, mountpoint, output file)
2. Checks if the specified Ceph user exists
3. Verifies that the subvolume group and subvolume exist
4. Creates a minimal ceph.conf configuration file
5. Exports the Ceph user's key and keyring
6. Generates mount configuration files using templates:
   - mount.sh script
   - fstab.content
   - systemd mount unit
   - systemd automount unit
7. Packages all generated files into a tar archive

## Validation
- Ensures username is specified and not "admin"
- Verifies Ceph user exists
- Checks subvolume group and subvolume existence

## Configuration Files Generated
- `ceph.conf`: Minimal Ceph configuration with FSID and monitor hosts
- `mount.sh`: Script for mounting the CephFS subvolume
- `fstab.content`: fstab entry for the mount
- `*.mount`: systemd mount unit file
- `*.automount`: systemd automount unit file

## Output
- Creates a tar archive containing all generated configuration files
- The archive can be extracted on the client host to set up CephFS mounting

## Dependencies
- Requires existing Ceph user created with `cephos-cephfs-user` script
- Requires existing subvolume group and subvolume

## Notes
- The script does not create Ceph users or subvolumes; these must exist beforehand
- The generated archive contains all necessary files for client-side CephFS mounting
- The mountpoint path should be absolute and exist on the client system
