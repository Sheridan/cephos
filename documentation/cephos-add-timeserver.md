# cephos-add-timeserver

## Description
The `cephos-add-timeserver` script is used to configure time server settings for the CephOS system. It adds a specific time server host and a time server pool to the system's chrony configuration. Both options must be specified.

## Options
- `-s <host>`: Specify the time server host (required)
- `-p <host>`: Specify the time servers pool (required)
- `-h`: Display this help message
- `-v`: Enable verbose output

## Examples
```bash
# Add both time server host and pool with verbose output
cephos-add-timeserver -s time.domain.local -p 0.pool.ntp.org -v
```

## Functionality
1. Adds the specified time server(s) to chrony configuration
1. Enables and starts the chrony service
1. Sets NTP to enabled

## Files Modified
- `/etc/chrony/sources.d/{address}.sources`
- System services (chrony)
