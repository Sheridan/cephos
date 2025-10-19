#!/bin/bash

live_build="lb --color" #--verbose
project_dir="${HOME}/project"
work_dir="${HOME}/work"
live_build_dir="${work_dir}/live_build"
live_build_config_dir="${live_build_dir}/config"
tmp_dir="${work_dir}/tmp"

function get_branch_name()
{
  local env_branch_name="${GITHUB_REF_NAME:-}"
  local result_branch_name
  if [[ -n "${env_branch_name}" ]]
  then
    result_branch_name="${env_branch_name}"
  else
    result_branch_name="development"
  fi
  echo "${result_branch_name}"
}

function install_smartcl_exporter
{
  echo "Installing smartcl_exporter"
  local sc_workdir="${tmp_dir}/smartcl_exporter"
  local version="0.14.0"
  mkdir -p "${sc_workdir}"
  curl -fsSL "https://github.com/prometheus-community/smartctl_exporter/releases/download/v${version}/smartctl_exporter-${version}.linux-amd64.tar.gz" -o "${sc_workdir}/smartctl_exporter.tar.gz"
  tar -xzf "${sc_workdir}/smartctl_exporter.tar.gz" -C "${sc_workdir}"
  find "${sc_workdir}" -type f -name 'smartctl_exporter' -exec mv -t "${live_build_config_dir}/includes.chroot_after_packages/usr/local/bin/" {} +
  ls -la ${live_build_config_dir}/includes.chroot_after_packages/usr/local/bin/smartctl_exporter
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
	cp "${live_build_config_dir}/archives/${name}.key.chroot"  "${live_build_config_dir}/archives/${name}.key.binary"
}

function prepare_config()
{
	echo "Preparing data..."
  extract_templates

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

  install_smartcl_exporter
}

function make_splash_image()
{
  echo "Publishing CephOS splash"
  mkdir -p "${live_build_config_dir}/bootloaders/syslinux"
  ${project_dir}/tools/logo-to-splash.sh "${project_dir}/logo.png" "${live_build_config_dir}/bootloaders/syslinux/splash.png"
}

function publish_info()
{
  echo "Publishing CephOS info"
	echo "$(get_branch_name)"                 > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_version
	echo "https://github.com/Sheridan/cephos" > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_repository
	echo "https://t.me/ceph_os"               > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_telegram
  echo "$(date --utc)"                      > ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_build_date
}

function generate_motd()
{
  echo "Generating MOTD"
  local input_file="${project_dir}/COMMAND_LIST.md"
  local motd_file="${live_build_config_dir}/includes.chroot_after_packages/etc/motd"

  local color_green="\e[1;32m"
  local color_yllow="\e[1;33m"
  local color_reset="\e[0m"
  echo -e "${color_yllow}" > "${motd_file}"
  cat ${live_build_config_dir}/includes.chroot_after_packages/etc/cephos_live_ascii >> "${motd_file}"
  echo -e "${color_reset}" >> "${motd_file}"

  while IFS='|' read -r _ col_command col_description _
  do
    [[ "$col_command" == *"Command"* ]] && continue
    [[ "$col_command" == *"---"* ]] && continue
    [[ -z "$col_command" ]] && continue

    local command_name
    command_name=$(echo "$col_command" | sed -E 's/.*\[(.+?)\].doc.*/\1/' | xargs)
    local description
    description=$(echo "$col_description" | xargs)
    [[ -z "${command_name}" ]] && continue

    printf "  ${color_green}%-30s${color_reset} %s\n" "${command_name}" "${description}" >> "${motd_file}"
  done < "$input_file"
  echo -e "\n" >> "$motd_file"
}

function configure()
{
	echo "Configuring lb..."
	cd ${live_build_dir}
	${live_build} config \
        --apt-indices false \
        --apt-recommends false \
        --architecture amd64 \
        --archive-areas "main contrib non-free non-free-firmware" \
        --binary-images hdd \
        --bootappend-live "boot=live components hostname=cephos username=cephos noautologin persistence debugfs=off init=/usr/local/sbin/cephos-init" \
        --chroot-squashfs-compression-type lz4 \
        --compression lzip \
        --debian-installer none \
        --debootstrap-options "--include=apt-transport-https,ca-certificates,openssl --variant=minbase" \
        --distribution bookworm \
        --hdd-label CEPHOS \
        --initsystem systemd \
        --memtest memtest86+ \
        --system live

  # toram -> --bootappend-live

  publish_info
  make_splash_image
  set_syslinux_timeout
  generate_motd
}

function extract_templates()
{
  local to_path="${tmp_dir}/lb_templates"
  mkdir -p "${to_path}"
  cp -r /usr/share/live/ ${to_path}/
}

function set_syslinux_timeout()
{
  local timeout="50"
  local bootloader_dir="${live_build_config_dir}/bootloaders/syslinux"
  local config_cfg_prod="${bootloader_dir}/syslinux.cfg"

  mkdir -p "${bootloader_dir}"

  if [ ! -f "${config_cfg_prod}" ]
  then
    cp /usr/share/live/build/bootloaders/syslinux/syslinux.cfg "${config_cfg_prod}"
  fi

  if grep -q "^timeout " "${config_cfg_prod}"
  then
    sed -i "s/^timeout .*/timeout ${timeout}/" "${config_cfg_prod}"
  else
    echo "timeout ${timeout}" >> "${config_cfg_prod}"
  fi

  echo "CephOS syslinux timeout: ${timeout}s"
}

function build()
{
	echo "Building image..."

  local builded_raw_file="${live_build_dir}/live-image-amd64.img"
	local result_run_file="${work_dir}/cephos_installer.run"
  local result_raw_file="${work_dir}/cephos.img"
  local result_logo_file="${work_dir}/cephos_logo.png"

	cd ${live_build_dir}
  sudo ${live_build} build

	cat ${project_dir}/tools/run_header.sh "${builded_raw_file}" > "${result_run_file}"
	chmod oga+x "${result_run_file}"
  cp "${builded_raw_file}" "${result_raw_file}"
  cp "${live_build_config_dir}/bootloaders/syslinux/splash.png" "${result_logo_file}"
  ls -lah "${result_run_file}" "${result_raw_file}" "${result_logo_file}" | awk '{ print $5 " " $9}'
}

function clean()
{
	echo "Cleaning data..."
	sudo rm -rf ${live_build_dir}
}
trap clean EXIT
trap clean ERR
trap clean INT
trap clean TERM

prepare_config
configure
build
