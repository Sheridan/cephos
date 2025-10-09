# cephos-init-host

## Description
The `cephos-init-host` script initializes a host for use in a Ceph cluster. It configures network settings, hostname, and timezone.

## Options
- `-n <fqdn>`: (Required) Specify the Fully Qualified Domain Name (FQDN) for the host
- `-P <public_network>`: (Required) Specify the public network in CIDR notation (e.g., 10.10.0.0/24)
- `-C <cluster_network>`: (Optional) Specify the cluster network in CIDR notation (e.g., 10.20.0.0/24)
- `-p <public_ip>`: (Required) Specify the public IP address for this host
- `-c <cluster_ip>`: (Optional) Specify the cluster IP address for this host
- `-z <timezone>`: (Optional) Specify the host timezone
- `-h`: Display this help message
- `-v`: Enable verbose output

## Examples
```bash
# Initialize host with FQDN
cephos-init-host -n ceph-first.domain.local -P 10.10.0.0/24 -C 10.20.0.0/24 -p 10.10.0.100 -c 10.20.0.100
```

## Functionality
1. Validates required options (hostname, networks, IPs)
1. Sets timezone if specified
1. Configures cluster environment variables
1. Sets node environment variables
1. Updates `/etc/hosts` with host entries
1. Sets hostname and domain if needed
1. Restarts shell to apply environment changes

## Network Configuration
- Sets public and cluster network environment variables
- Configures public and cluster IP addresses
- Updates host entries in `/etc/hosts`

## Host Configuration
- Validates FQDN format
- Sets hostname and domain
- Restarts shell to apply changes

## Dependencies
- Depends on proper network configuration
