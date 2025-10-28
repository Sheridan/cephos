# cephos-ups-setup

The `cephos-ups-setup` script configures and enables power monitoring for Uninterruptible Power Supplies (UPS) using the Network UPS Tools (NUT) services. It supports SNMP-based communication (v1 and v2c) with the UPS device. The script generates configuration files for NUT, sets up random passwords for monitoring, and enables the necessary systemd services.

This script is typically run as part of the CephOS setup to ensure reliable power monitoring in cluster environments.

## Usage

```
cephos-ups-setup -m <mode> -c <snmp_community> -p <port> -d <desc> -l <low_battery_%>
```

Sets up and starts power monitoring using NUT services.

### Options

- `-m <mode>`: Specify the target mode (default: `snmp_v2c`).
  - Supported modes: `snmp_v1`, `snmp_v2c`
- `-c <snmp_community>`: Specify the SNMP community (default: `public`).
- `-p <port>`: Specify the target port.
  - For SNMP: The UPS address (or hostname).
- `-d <desc>`: Specify target description (default: `UPS`).
- `-l <low_battery_%>`: Specify the low battery percent (default: `30`). Must be an integer.
- `-h`: Show this help message.
- `-v`: Enable verbose output.

### Examples

Connect to SNMP v2c UPS:
```
cephos-ups-setup -m snmp_v2c -c trippline -p ups-trippline.domain.local -d "My main UPS"
```

After running the script, use `cephos-ups-status` script to test UPS communication:
```
cephos-ups-status
```

This will output the UPS status via `upsc` command.

## Generated Files and Services

- **Configuration Files**:
  - `/etc/nut/upsd.users`: User configurations for the UPS daemon.
  - `/etc/nut/upsmon.conf`: Monitoring configuration.
  - `/etc/nut/ups.conf`: UPS driver and device configuration (SNMP-specific).

- **Systemd Services Enabled**:
  - `nut-monitor.service`: Monitors UPS events.
  - `nut-server.service`: Runs the UPS daemon (upsd).

## Notes

- Random 8-character passwords are generated for admin and monitor users.
- For more details on NUT, refer to the [official NUT documentation](https://networkupstools.org/).
