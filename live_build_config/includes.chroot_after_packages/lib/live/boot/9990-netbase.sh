#!/bin/sh

make_interface_conf()
{
	local IF_PATH="${1}"
	local INTERFACE_NAME="${2}"
	local CONF_PATH="${IF_PATH}/${INTERFACE_NAME}"

	echo "Saving interface ${INTERFACE_NAME} conf to ${CONF_PATH}"

	cat <<EOF > "${CONF_PATH}"
# Generated at first start
auto ${INTERFACE_NAME}
allow-hotplug ${INTERFACE_NAME}
iface ${INTERFACE_NAME} inet dhcp
EOF
}

Netbase()
{
	IF_PATH="/root/etc/network/interfaces.d"
	FLAG_PATH="/root/var/lib/live/config"

	FLAG_FILE="${FLAG_PATH}/netbase-cephos"
	if [ ! -f "${FLAG_FILE}" ]
	then
		echo "First time network interfaces configuration"

		udevadm trigger
		udevadm settle

		mkdir -p "${IF_PATH}"
		for INTERFACE_PATH in /sys/class/net/*
		do
			if [ -d "${INTERFACE_PATH}/device" ]
			then
				INTERFACE_NAME="$(basename "${INTERFACE_PATH}")"
				make_interface_conf "${IF_PATH}" "${INTERFACE_NAME}"
			fi
		done

		mkdir -p "${FLAG_PATH}"
		touch "${FLAG_FILE}"
	fi
}
