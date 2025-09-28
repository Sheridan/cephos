![CephOS logo](logo.png)

# cephos
CephOS is a Debian Live-based distribution designed for lightweight NAS and SOHO environments.
It boots from a USB flash drive, provisions local disks for Ceph.

The distribution is primarily focused on CephFS, but all Ceph features are still available.

Telegram channel: https://t.me/ceph_os

# Installation on a USB Flash Drive
You need to run `cephos_installer.run`, specifying your target block device (for example, your USB flash drive) as the root device.

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
1. Write image to a device, create persistence on another device, and map additional directories: `bash ./cephos_installer.run -R /dev/sdi -P /dev/sdj -p "/dev/sdm:/var/log;/dev/sdn:/var/cache"`
1. Update image while keeping persistence on the same device: ` ./cephos_installer.run -m update -R /dev/sdi`
1. Write only the CephOS image (no persistence): `./cephos_installer.run -s -R /dev/sdi`

## Notes
The script will create at least one persistence partition. The size of this partition depends on the capacity of the device. Since persistence is intended to store system changes, please avoid using small-capacity flash drives. For testing, a 128GB drive is recommended.

Attention! The usual warning: back up the data from your flash drive first, otherwise it will be lost :)

# Creating the First Node
1. Set the hostname: `cephos-init-host -v -n hostname.domain.local`
1. Initialize the cluster database. You need to specify the public (-P) and private (-C) networks, as well as the public (-p) and private (-c) IPs: `cephos-init-cluster -v -P 10.0.0.0/8 -C 10.0.0.0/8 -p 10.0.2.15 -c 10.0.2.15`
1. Initialize the monitor: `cephos-init-mon -v`
1. Add block devices. Run the command for each device: `cephos-append-disk -v -d /dev/vdc`
1. Initialize the manager: `cephos-init-mgr -v`
1. Initialize CephFS: `cephos-init-cephfs -v`

# Defaults
## linux
- Login: cephos
- Password: cephos

## dashboard
- Login: cephos
- Password: P@ssw0rd
