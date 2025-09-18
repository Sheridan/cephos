![CephOS logo](logo.png)

# cephos
CephOS is a Debian Live-based distribution designed for lightweight NAS and SOHO environments.
It boots from a USB flash drive in read-only mode, provisions local disks for Ceph.

# defaults
Login: cephos
Password: cephos

# example
```
cephos$ cephos-init-host -v -n cf.domain.local
cephos$ cephos-init-cluster -v -p 10.0.0.0/8 -c 10.0.0.0/8
cephos$ cephos-init-mon -v -P 10.0.2.15
cephos$ cephos-append-disk -v -d /dev/vdb
```
