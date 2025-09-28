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
cephos-init-host -v -n cf.domain.local
cephos-init-cluster -v -P 192.168.0.0/24 -C 192.168.1.0/24 -p 192.168.0.10 -c 192.168.1.10
cephos-init-mon -v
cephos-append-disk -v -d /dev/vdb
cephos-append-disk -v -d /dev/vdc
cephos-init-mgr -v
cephos-init-cephfs -v
```

## host ceph-second
```
cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.11 -n public_0
cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.11 -n ceph_0
cephos-init-host -v -n cs.domain.local
cephos-connect-to-cluster -v -n 192.168.0.10 -c 192.168.1.10

cephos-append-disk -v -d /dev/vdb
cephos-append-disk -v -d /dev/vdc
```

## host ceph-third
```
cephos-setup-interface -i ens4 -m 255.255.255.0 -a 192.168.0.12 -n public_0
cephos-setup-interface -i ens5 -m 255.255.255.0 -a 192.168.1.12 -n ceph_0
cephos-init-host -v -n ct.domain.local
cephos-connect-to-cluster -v -n 192.168.0.11 -c 192.168.1.10

cephos-append-disk -v -d /dev/vdb
cephos-append-disk -v -d /dev/vdc
```
