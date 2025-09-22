#!/bin/bash

live_build="lb --color --verbose"
project_dir="${HOME}/project"
work_dir="${HOME}/work"
live_build_dir="${work_dir}/live_build"
live_build_config_dir="${live_build_dir}/config"
tmp_dir="${work_dir}/tmp"

function get_branch_name()
{
  local env_branch_name="${GITHUB_REF_NAME:-}"
  local result_branch_name
  if [[ -n "$env_branch_name" ]]
  then
    result_branch_name="$env_branch_name"
  else
    result_branch_name="development"
  fi
  echo "$result_branch_name"
}

function add_repo()
{
	local name="$1"
	local repo_url="$2"
	local key_url="$3"

	echo "Adding repository ${name} from ${repo_url} with key ${key_url}"
	echo "deb ${repo_url}" > "${live_build_config_dir}/archives/${name}.list.chroot"

	local tmpkey="${tmp_dir}/${name}.key"
	local gpg_key="${tmp_dir}/${name}.gpg"
	curl -fsSL "${key_url}" -o "${tmpkey}"

	gpg --dearmor < "${tmpkey}" > "${gpg_key}"
	gpg --no-default-keyring --keyring "${gpg_key}" --export --armor > "${live_build_config_dir}/archives/${name}.key.chroot"

	cp "${live_build_config_dir}/archives/${name}.list.chroot" "${live_build_config_dir}/archives/${name}.list.binary"
	cp "${live_build_config_dir}/archives/${name}.key.chroot" "${live_build_config_dir}/archives/${name}.key.binary"
}


function prepare_config()
{
	echo "Preparing data..."
	mkdir -p ${live_build_config_dir} ${tmp_dir}

	rsync \
		-rlpt \
		--delete \
		--no-owner \
		--no-group \
		--verbose \
		"${project_dir}/live_build_config/" "${live_build_config_dir}/"

	mkdir -p "${live_build_config_dir}/archives"

	add_repo "influxdata" "https://repos.influxdata.com/debian stable main"      "https://repos.influxdata.com/influxdata-archive_compat.key"
	add_repo "ceph"       "https://download.ceph.com/debian-squid bookworm main" "https://download.ceph.com/keys/release.asc"

	${project_dir}/tools/logo-to-splash.sh "${project_dir}/logo.png" "${live_build_config_dir}/bootloaders/syslinux/splash.png"

	echo "$(get_branch_name)"                 > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_version
	echo "https://github.com/Sheridan/cephos" > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_repository
	echo "https://t.me/ceph_os"               > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_telegram
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
