# Examples (for testing with qemu)

## writing flash's
```
for d in i j k ; do echo "y" | tmp/work/cephos_installer.run -R /dev/sd$d  ; done
```

## starting vm's
```
testing/quemu-start.sh -s "cf:/dev/sdi;cs:/dev/sdj;ct:/dev/sdk"
```

## host ceph-first
```
cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.10 -n public_0
cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.10 -n ceph_0
cephos-init-host -v -n cf.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.10 -c 192.168.1.10
cephos-add-timeserver -v -s 10.0.0.1 -p ru.pool.ntp.org
cephos-init-cluster -v
cephos-disk-add -v -d /dev/vdb
cephos-disk-add -v -d /dev/vdc
cephos-init-cephfs -v
cephos-init-metrics -v
```

## host ceph-second
```
cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.11 -n public_0
cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.11 -n ceph_0
cephos-init-host -v -n cs.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.11 -c 192.168.1.11
cephos-connect-to-cluster -v -n 192.168.0.10
cephos-disk-add -v -d /dev/vdb
cephos-disk-add -v -d /dev/vdc
cephos-init-mds -v
cephos-init-metrics -v
```

## host ceph-third
```
cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.12 -n public_0
cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.12 -n ceph_0
cephos-init-host -v -n ct.domain.local -z "Europe/Moscow" -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.12 -c 192.168.1.12
cephos-connect-to-cluster -v -n 192.168.0.11
cephos-disk-add -v -d /dev/vdb
cephos-disk-add -v -d /dev/vdc
cephos-init-mds -v
cephos-init-metrics -v
```

## mount
```
ceph auth get-or-create client.cephfsuser mon 'allow r' mds 'allow r, allow rw path=/' osd 'allow rw pool=storage_data'
ceph auth get client.cephfsuser > /cephos/ceph/conf/ceph.client.cephfsuser.keyring
ceph auth get-key client.cephfsuser > /cephos/ceph/conf/cephfsuser.secret
mkdir -p /mnt/cephos
mount -t ceph 192.168.0.10,192.168.0.20,192.168.0.30:/ /mnt/cephos -o name=cephfsuser,secretfile=/cephos/ceph/conf/cephfsuser.secret
```
## using mount helper
```
# in dashboard make groups and subvolumes
cephos-cephfs-user -v -a -u sheridan -g user -s sheridan
cephos-cephfs-mount-helper -u sheridan -g user -s sheridan -p /mnt/sheridan -o ~/mnt-helper/sheridan.tar
```

## misc
```
sudo ceph config set mon mon_clock_drift_allowed 1
```

# polygon
## ssh
```
for n in mirzamon alpherat zubenelh; do ssh-keygen -R cephos-$n; ssh-copy-id cephos@cephos-$n; done
```

## mirzamon
```
ssh cephos@cephos-mirzamon
cephos-setup-interface -i enp2s0 -d -n public_0
cephos-setup-interface -i enp1s0 -m 255.255.255.0 -a 172.16.16.1 -n ceph_0
cephos-init-host -v -n cephos-mirzamon.sheridan-home.local -z "Europe/Moscow" -P 10.0.0.0/8 -C 172.16.16.0/24 -p 10.0.1.24 -c 172.16.16.1
cephos-force-timesync -v -s 10.0.0.1
cephos-add-timeserver -v -s 10.0.0.1 -p ru.pool.ntp.org
cephos-init-cluster -v
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000VX000-1CU164_W1E8FT7Q
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000DM006-2DM164_Z4Z7J05N
cephos-init-cephfs -v
cephos-init-metrics -v
```

## alpherat
```
ssh cephos@cephos-alpherat
cephos-setup-interface -i enp2s0 -d -n public_0
cephos-setup-interface -i enp1s0 -m 255.255.255.0 -a 172.16.16.2 -n ceph_0
cephos-init-host -v -n cephos-alpherat.sheridan-home.local -z "Europe/Moscow" -P 10.0.0.0/8 -C 172.16.16.0/24 -p 10.0.1.25 -c 172.16.16.2
cephos-force-timesync -v -s 10.0.0.1
cephos-connect-to-cluster -v -n 10.0.1.24
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000DM001-1CH164_W1E6JGT2
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000VX000-1CU164_Z1E2J076
cephos-init-mds -v
cephos-init-metrics -v
```
## zubenelh
```
ssh cephos@cephos-zubenelh
cephos-setup-interface -i enp2s0 -d -n public_0
cephos-setup-interface -i enp1s0 -m 255.255.255.0 -a 172.16.16.3 -n ceph_0
cephos-init-host -v -n cephos-zubenelh.sheridan-home.local -z "Europe/Moscow" -P 10.0.0.0/8 -C 172.16.16.0/24 -p 10.0.1.26 -c 172.16.16.3
cephos-force-timesync -v -s 10.0.0.1
cephos-connect-to-cluster -v -n 10.0.1.25
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000DM001-1ER164_Z4Z3NC3E
cephos-disk-add -v -d /dev/disk/by-id/ata-ST2000DM001-1CH164_W1E6HS6T
cephos-init-mds -v
cephos-init-metrics -v
```

## finally
```
cephos-cephfs-compression -v -a lz4 -m aggressive -r 0.9
ceph dashboard set-prometheus-api-host http://prometheus.domain.local
cephos-conf-sync -v
```

## mount
```
# in dashboard make groups and subvolumes
cephos-cephfs-user -v -a -u sheridan -g user -s sheridan
cephos-cephfs-mount-helper -u sheridan -g user -s sheridan -p /mnt/sheridan -o ~/mnt-helper/sheridan.tar
```
