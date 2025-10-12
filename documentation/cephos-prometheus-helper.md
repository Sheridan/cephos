# cephos-prometheus-helper

## Description

The `cephos-prometheus-helper` script generates a Prometheus Service Discovery (SD) configuration file based on a template. It creates configurations for various exporters that can then be used by Prometheus to collect metrics from a Ceph cluster.

## Usage

```bash
cephos-prometheus-helper -o <filename> [-v]
```

## Options

- `-o <filename>`: Specifies the output file.
- `-h`: Displays this help message.
- `-v`: Enables verbose output for debugging.

## Examples

```bash
# Generate configuration file with verbose output
cephos-prometheus-helper -o ~/cephos_yaml.yaml -v
```
