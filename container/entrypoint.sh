#!/bin/bash

live_build="lb --color --verbose"
project_dir="${HOME}/project"
work_dir="${HOME}/work"
live_build_dir="${work_dir}/live_build"
tmp_dir="${work_dir}/tmp"

function add_repo()
{
    local name="$1"
    local repo_url="$2"
    local key_url="$3"

		echo "Adding repository ${name} from ${repo_url} with key ${key_url}"

    echo "deb ${repo_url}" > "${live_build_dir}/config/archives/${name}.list.chroot"
    cp "${live_build_dir}/config/archives/${name}.list.chroot" "${live_build_dir}/config/archives/${name}.list.binary"

    tmpkey="${tmp_dir}/${name}.key"
		gpg_key="${tmp_dir}/${name}.gpg"
    curl -fsSL "${key_url}" -o "${tmpkey}"

    gpg --dearmor < "${tmpkey}" > "${gpg_key}"
    gpg --no-default-keyring --keyring "${gpg_key}" --export --armor > "${live_build_dir}/config/archives/${name}.key.chroot"

    cp "${live_build_dir}/config/archives/${name}.key.chroot" "${live_build_dir}/config/archives/${name}.key.binary"
}


function prepare_config()
{
	echo "Preparing data..."
	mkdir -p ${live_build_dir}/config ${tmp_dir}

	rsync \
		-rlpt \
		--delete \
		--no-owner \
		--no-group \
		--verbose \
		"${project_dir}/live_build_config/" "${live_build_dir}/config/"

	mkdir -p "${live_build_dir}/config/archives"

	add_repo "influxdata" "https://repos.influxdata.com/debian stable main" "https://repos.influxdata.com/influxdata-archive_compat.key"
	add_repo "ceph" "https://download.ceph.com/debian-squid bookworm main" "https://download.ceph.com/keys/release.asc"
}

function configure()
{
	echo "Configuring lb..."
	cd ${live_build_dir}
	${live_build} config \
						--apt-indices false \
						--architecture amd64 \
						--archive-areas "main contrib non-free non-free-firmware" \
						--binary-images hdd \
						--chroot-squashfs-compression-type lz4 \
						--debian-installer none \
						--debootstrap-options "--include=apt-transport-https,ca-certificates,openssl --variant=minbase" \
						--distribution bookworm \
						--hdd-label CephOS \
						--system live \
  					--apt-recommends false \
						--memtest memtest86+ \
    				--bootappend-live "boot=live components username=cephos noautologin persistence debugfs=off"
}

function build()
{
	echo "Building image..."
	local result_img_file="${live_build_dir}/live-image-amd64.img"
	local result_run_file="${work_dir}/cephos_installer.run"
	cd ${live_build_dir}
  sudo ${live_build} build
	cat ${project_dir}/tools/run_header.sh "${result_img_file}" > "${result_run_file}"
	chmod oga+x "${result_run_file}"
	ls -lah "${result_run_file}"
}

function clean()
{
	echo "Cleaning data..."
	sudo rm -rf ${live_build_dir}
}
trap clean EXIT SIGINT SIGTERM

prepare_config
configure
build
