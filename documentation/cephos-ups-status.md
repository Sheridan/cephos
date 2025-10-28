# cephos-ups-status

## Overview

The `cephos-ups-status` command-line tool is used to display the current status of the UPS (Uninterruptible Power Supply) device in a CephOS environment. It leverages the Network UPS Tools (NUT) configuration to retrieve and show UPS information.

## Prerequisites

- NUT must be configured. If not configured, use `cephos-ups-setup` to set it up.

## Functionality

The script performs the following steps:

1. **Configuration Check**: Verifies the existence of `/etc/nut/ups.conf`. If absent, it logs a warning and suggests using `cephos-ups-setup`.
1. **Status Retrieval**:
   - Extracts the UPS driver name
   - Retrieves the UPS description
   - Executes `upsc ${driver_name}@localhost` to fetch and display detailed UPS status variables.

## Troubleshooting

- **"NUT is not configured"**: Run `cephos-ups-setup` to configure NUT.

## Related Commands

- `cephos-ups-setup`: Configure NUT for UPS monitoring.
