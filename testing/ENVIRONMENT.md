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
cephos-connect-to-cluster -v -n 192.168.0.11 -p 192.168.0.12 -c 192.168.1.12
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
