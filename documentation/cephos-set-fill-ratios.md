# cephos-set-fill-ratios

## Description

The `cephos-set-fill-ratios` script is used to configure the fill ratios for a Ceph cluster. It sets three important OSD (Object Storage Daemon) ratios that control when Ceph considers a storage device to be near full, backfill full, or completely full.

## Usage

```bash
cephos-set-fill-ratios -n <ratio> -b <ratio> -f <ratio> [-hv]
```

## Options

- `-n <ratio>`: Set the nearfull-ratio (default: 0.85)
- `-b <ratio>`: Set the backfillfull-ratio (default: 0.9)
- `-f <ratio>`: Set the full-ratio (default: 0.95)
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Ratios Explanation
1. **nearfull-ratio**: When the storage usage reaches this ratio, Ceph will start considering the device as near full. This triggers certain behaviors to prevent the device from becoming completely full. (Default: 0.85)
1. **backfillfull-ratio**: When the storage usage reaches this ratio, Ceph will consider the device as backfill full. This affects backfill operations where data is being moved to balance the cluster. (Default: 0.9)
1. **full-ratio**: When the storage usage reaches this ratio, Ceph will consider the device as completely full. No new data will be written to the device until space is freed up. (Default: 0.95)

## Validation

The script validates that the ratios are set in the correct order:
`nearfull-ratio < backfillfull-ratio < full-ratio`

If the ratios are not in the correct order, the script will display an error and exit.

## Example Usage

```bash
# Set custom ratios
cephos-set-fill-ratios -n 0.80 -b 0.85 -f 0.90

# Show help
cephos-set-fill-ratios -h

# Run with verbose output and set ratios to defaults
cephos-set-fill-ratios -v
```

## Default Values

If no options are provided, the script will use the following default values:
- nearfull-ratio: 0.85
- backfillfull-ratio: 0.9
- full-ratio: 0.95
