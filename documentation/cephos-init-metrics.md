# cephos-init-metrics

## Description
The `cephos-init-metrics` script initializes metrics collection services on a Ceph node. It enables various exporters and monitoring services to collect performance data.

## Options
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Functionality
1. Enables node exporter service (port 9100)
1. Enables Telegraf service (port 9102)
1. Enables Smartctl exporter service (port 9104)
1. Enables Ceph exporter service (port 9106)
1. Configures Ceph internal metrics (port 9108)
1. Enables Prometheus module in Ceph Manager

## Services Enabled
- `prometheus-node-exporter`: System metrics collection
- `telegraf`: Data collection agent
- `smartctl-exporter`: Disk health metrics
- `ceph-exporter`: Ceph-specific metrics
- `ceph mgr prometheus`: Internal Ceph metrics

## Configuration
- Configures Prometheus server address and port
- Enables Prometheus module in Ceph Manager
