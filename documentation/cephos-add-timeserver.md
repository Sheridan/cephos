# cephos-add-timeserver

## Description
The `cephos-add-timeserver` script is used to configure time server settings for the CephOS system. It allows adding either a specific time server host or a time server pool to the system's chrony configuration.

## Options
- `-s <host>`: Specify the time server host
- `-p <host>`: Specify the time servers pool
- `-h`: Display this help message
- `-v`: Enable verbose output

## Examples
```bash
# Add a time server pool
cephos-add-timeserver -p 0.pool.ntp.org

# Add a specific time server with verbose output
cephos-add-timeserver -s time.domain.local -v
```

## Functionality
1. Adds the specified time server(s) to chrony configuration
1. Enables and starts the chrony service
1. Sets NTP to enabled

## Files Modified
- `/etc/chrony/sources.d/{address}.sources`
- System services (chrony)
