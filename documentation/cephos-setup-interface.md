# cephos-setup-interface

## Description
The `cephos-setup-interface` script configures network interfaces on CephOS systems. It supports both static IP and DHCP configurations.

## Options
- `-i <interface>`: (Required) Specifies the network interface to configure
- `-n <new_interface_name>`: (Optional) Specifies a new name for the interface
- `-a <address>`: (Required for static IP) The IP address to assign
- `-m <netmask>`: (Required for static IP) The netmask for the interface
- `-d`: (Optional) Enable DHCP mode (cannot be used with `-a` and `-m`)
- `-v`: (Optional) Enable verbose output
- `-h`: (Optional) Display this help message

## Examples
```bash
# Configure eth0 with static IP
cephos-setup-interface -i eth0 -a 192.168.1.100 -m 255.255.255.0

# Configure eth0 with DHCP and rename to public_0
cephos-setup-interface -i eth0 -d -n public_0
```

## Functionality
1. Validates interface name and options
1. Configures interface with either static IP or DHCP
1. Creates udev rules for persistent interface naming
1. Handles interface renaming and configuration persistence

## Interface Configuration
- Supports both static IP and DHCP configurations
- Validates IP address and netmask formats
- Creates interface configuration files in `/etc/network/interfaces.d/`
- Sets up udev rules for persistent interface naming

## Persistence
- Creates udev rules for interface name persistence across reboots
- Configures interfaces to maintain settings after reboot
