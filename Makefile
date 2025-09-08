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
						--distribution bookworm \
						--debootstrap-options "--include=apt-transport-https,ca-certificates,openssl" \

build: configure
	cd lb && sudo $(LB) build 2>&1

clean:
	cd lb && sudo $(LB) clean

purge:
	cd lb && sudo $(LB) clean --purge
