# cephos-cephfs-compression

## Description

The `cephos-cephfs-compression` script configures compression settings for a CephFS filesystem's data pool. It sets the compression mode, algorithm, and required ratio to optimize storage usage.


## Usage

```bash
cephos-cephfs-compression [-f <filesystem>] [-m <mode>] [-a <algorithm>] [-r <ratio>] [-h] [-v]
```

## Options

- `-f <filesystem>`: CephFS name to configure (default: the default CephFS name, typically 'cephfs')
- `-m <mode>`: Compression mode (default: 'none'). Available modes are shown in the help output.
- `-a <algorithm>`: Compression algorithm (default: 'snappy'). Available algorithms are shown in the help output.
- `-r <ratio>`: Minimum compression ratio required (default: '0.875'). Must be a float between 0 and 1.
- `-h`: Display help message with available options, modes, and algorithms, then exit.
- `-v`: Enable verbose logging during execution.

## Prerequisites

- Ceph cluster must be initialized and running.
- The specified CephFS must exist (use `ceph fs ls` to verify).
- Run as a user with sudo privileges for Ceph commands.

## Example Usage

### Set Compression Settings

Apply force compression using the zlib algorithm with a 0.9 ratio for the default CephFS:

```bash
cephos-cephfs-compression -m force -a zlib -r 0.9
```

For a specific CephFS named 'mycephfs':

```bash
cephos-cephfs-compression -f mycephfs -m passive -a snappy -r 0.8 -v
```

## Notes

- Changes take effect immediately on the data pool but may require client reconnection for full impact.
