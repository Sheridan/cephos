![CephOS logo](logo.png)

# cephos
CephOS is a Debian Live-based distribution designed for lightweight NAS and SOHO environments.
It boots from a USB flash drive in read-only mode, provisions local disks for Ceph.

The distribution is primarily focused on CephFS, but all Ceph features are still available.

Telegram channel: https://t.me/ceph_os

# Installation on a USB Flash Drive
You need to run `cephos_installer.run`, specifying your flash drive as the block device. For example: `cephos_installer.run /dev/sdm`
The script will create two partitions on the flash drive: the first for the distribution image, and the second, called “persistence,” where changes will be saved.
I understand that small flash drives are hard to find nowadays, but please try not to use low-capacity ones, as the size of the second partition depends on this. For now, it’s unclear how large it needs to be. For testing, I’m using a 128GB flash drive.

Attention! The usual warning: back up the data from your flash drive first, otherwise it will be lost :)

# Creating the First Node
1. Set the hostname:
   `cephos-init-host -v -n hostname.domain.local`
1. Initialize the cluster database. You need to specify the public (-P) and private (-C) networks, as well as the public (-p) and private (-c) IPs:
   `cephos-init-cluster -v -P 10.0.0.0/8 -C 10.0.0.0/8 -p 10.0.2.15 -c 10.0.2.15`
1. Initialize the monitor:
   `cephos-init-mon -v`
1. Add block devices. Run the command for each device:
   `cephos-append-disk -v -d /dev/vdc`
1. Initialize the manager:
   `cephos-init-mgr -v`
1. Initialize CephFS:
   `cephos-init-cephfs -v`

# Defaults
## linux
Login: cephos
Password: cephos

## dashboard
Login: cephos
Password: P@ssw0rd

# Example
```
cephos$ cephos-init-host -v -n cf.domain.local
cephos$ cephos-init-cluster -v -P 10.0.0.0/8 -C 10.0.0.0/8 -p 10.0.2.15 -c 10.0.2.15
cephos$ cephos-init-mon -v
cephos$ cephos-append-disk -v -d /dev/vdc
cephos$ cephos-init-mgr -v
cephos$ cephos-init-cephfs -v
```
