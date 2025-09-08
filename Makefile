.PHONY: build clean
LB := lb --color --verbose

configure:
	cd lb && $(LB) config \
						--architecture amd64 \
						--binary-images hdd \
						--apt-indices false \
						--chroot-squashfs-compression-type lz4 \
						--hdd-label CephOS \
						--system live \
					2>&1 | tee configure.log

build: configure
	cd lb && $(LB) build 2>&1 | tee build.log

clean:
	cd lb && $(LB) clean

purge:
	cd lb && $(LB) clean --purge
