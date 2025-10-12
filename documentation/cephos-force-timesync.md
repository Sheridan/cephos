# cephos-force-timesync

## Description
The `cephos-force-timesync` script performs a forced time synchronization with a specified time server. This is useful when the system time is highly desynchronized and needs to be corrected immediately.

## Options
- `-s <host>`: Specify the time server host
- `-h`: Display this help message
- `-v`: Enable verbose output

## Examples
```bash
# Force time sync with a specific time server
cephos-force-timesync -s time.domain.local -v
```

## Functionality
1. Stops the chrony service temporarily
1. Performs a forced time synchronization with the specified time server using `chronyd -q`
1. Restarts the chrony service

## Important Notes
- This operation may cause unpredictable consequences if the time is highly desynchronized
- The time server must be specified using the `-s` option
- Always review the confirmation prompt before proceeding
