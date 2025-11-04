![CephOS logo](logo.png)

# cephos
CephOS is a Debian Live-based distribution designed for lightweight NAS and SOHO environments.
It boots from a USB flash drive and provisions local disks for Ceph.

The distribution is primarily focused on CephFS, but all Ceph features are still available.

Telegram channel: https://t.me/ceph_os

[Commands list](COMMAND_LIST.md)

# Installation on a USB Flash Drive
You need to run `cephos_installer.run`, specifying your target block device (e.g., your USB flash drive) as the root device.

The script supports two working modes:
- **write** (default): Write the CephOS image and create persistence partitions.
- **update**: Update an existing installation without recreating persistence partitions.

## Options
- **`-m <mode>`**: Work mode (`write` | `update`). Default is `write`.
- **`-R <device>`**: Root block device (required, e.g. `/dev/sdi`).
- **`-P <device>`**: Root persistence block device. Default: second partition of the root device.
- **`-p "<device:mountpoint;...>"`**: Additional persistence block devices in the format `/dev/sdX:/path;/dev/sdY:/path`.
- **`-s`**: Only write the CephOS image to the block device (skip persistence creation).

## Examples
1. Write image to a device and create a persistence partition on the same device: `./cephos_installer.run -R /dev/sdi`
1. Write image to a device and create a persistence partition on a different device:`./cephos_installer.run -R /dev/sdi -P /dev/sdj`
1. Write image to a device, create persistence on another device, and map additional directories: `./cephos_installer.run -R /dev/sdi -P /dev/sdj -p "/dev/sdm:/var/log;/dev/sdn:/var/cache"`
1. Update image while keeping persistence on the same device: `./cephos_installer.run -m update -R /dev/sdi`
1. Write only the CephOS image (no persistence): `./cephos_installer.run -s -R /dev/sdi`

## Notes
The script will create at least one persistence partition. The size of this partition depends on the capacity of the device. Since persistence is intended to store system changes, please avoid using small-capacity flash drives. For testing, a 128GB drive is recommended.

Attention! The usual warning: back up the data from your flash drive first, otherwise it will be lost :)

## Recommendations
1. It is highly advisable to provide the storage with an uninterrupted power supply. In case of a power failure, shut down the cluster (`cephos-shutdown-cluster`).
1. After a reboot, the cluster may take a long time to recover. This is normal.
1. Avoid naming hosts with numerals (e.g., `cepos-1`, `cephos-ten`). Use names such as country names, stars, etc. CephOS creates a cluster of identical peer servers, and the naming convention will be reflected in the path.
1. It is highly recommended to have two network interfaces on each host. Assign the faster interfaces to the Ceph service network (`ceph_0`).

# Creating the First Node

1. **Configure network interfaces**
   Set up the public and cluster (optional) networks:
   ```bash
   cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.10 -n public_0
   cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.10 -n ceph_0
   ```

1. **Initialize the host**
   Configure hostname, timezone, and networks:
   ```bash
   cephos-init-host -v -n cf.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.10 -c 192.168.1.10
   ```

1. **Configure time synchronization**
   Add time servers for cluster synchronization:
   ```bash
   cephos-add-timeserver -v -s 10.0.0.1
   cephos-add-timeserver -v -p ru.pool.ntp.org
   ```

1. **Initialize the cluster database**
   Start the initial Ceph cluster configuration:
   ```bash
   cephos-init-cluster -v
   ```

1. **Add block devices**
   Append each device to the cluster:
   ```bash
   cephos-disk-add -v -d /dev/vdb
   cephos-disk-add -v -d /dev/vdc
   ```

1. **Enable cluster metrics**
   Initialize monitoring and metric collection:
   ```bash
   cephos-init-metrics -v
   ```

# Joining an Additional Node

1. **Configure network interfaces**
   Set up public and cluster (optional) networks for the new node:
   ```bash
   cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.11 -n public_0
   cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.11 -n ceph_0
   ```

1. **Initialize the host**
   Assign hostname, timezone, and network settings:
   ```bash
   cephos-init-host -v -n cs.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.11 -c 192.168.1.11
   ```

1. **Connect to the existing cluster**
   Join the cluster by connecting to the first node:
   ```bash
   cephos-connect-to-cluster -v -n 192.168.0.10
   ```

1. **Add block devices**
   Register local storage devices with the cluster:
   ```bash
   cephos-disk-add -v -d /dev/vdb
   cephos-disk-add -v -d /dev/vdc
   ```

1. **Enable metrics collection**
   Ensure monitoring and telemetry are active:
   ```bash
   cephos-init-metrics -v
   ```

# Finally
1. **Configuration sync**
   Run script `cephos-conf-sync` on any Ceph node to synchronize sensitive data between Ceph nodes
1. **Initialize CephFS**
   Set up the Ceph File System:
   ```bash
   cephos-cephfs-manager -a -v -f 'storage'
   ```

# Managing cephfs
1. Use the dashboard to create groups and subvolumes in CephFS
1. Use `cephos-cephfs-user` to create a user and assign them to a CephFS group/subvolume
1. Use `cephos-cephfs-mount-helper` to create a tar archive containing everything needed for mounting, including:
   - mount.sh command
   - fstab entries
   - systemd.mount/systemd.automount units

# Special `/cephos` Directory
This directory was created specifically to be placed on a persistent partition of a fast device.

Files listed [here](live_build_config/includes.chroot_after_packages/usr/local/share/cephos/init/files) and directories listed [here](live_build_config/includes.chroot_after_packages/usr/local/share/cephos/init/directories) are moved into this directory. A symlink is created to the original file location, and a `mount --bind` is created for the original directory location.

If this directory resides on a separate fast device, it serves two functions:

## Fast Data Access
The directory contains `/var/lib/ceph` with Ceph data. While OSDs store their metadata on their own disks, the MON stores its data here, so fast access is desirable.

## Quick Replacement of the Boot Flash Drive
All Ceph-related data required for the host are also stored in `/etc/hosts`, `/etc/hostname`, `/etc/systemd/system`, and so on. Ideally, I want to achieve a setup where simply plugging in the boot flash drive and booting the node is enough for it to immediately connect to the Ceph cluster, without the need to run connection scripts.

# Project build
1. Docker and the Docker Compose plugin must be installed.
1. Run `make build`.
1. After the build, the installer will appear in `tmp/work/`: `tmp/work/cephos_installer.run`.

# Defaults
## linux
- Login: cephos
- Password: cephos

The root user password is [complex and random](live_build_config/includes.chroot_after_packages/lib/live/config/0200-passwd). However, the user 'cephos' has the ability to use sudo.

## dashboard
- Login: cephos
- Password: P@ssw0rd
