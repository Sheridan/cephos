# cephos-cephfs-compression

## Description

The `cephos-cephfs-compression` script manages compression for CephFS volumes. It allows setting compression mode, algorithm, and required compression ratio for CephFS data pools.

## Usage

```bash
cephos-cephfs-compression -m mode -a algorithm -r ratio [-hv]
```

## Options

- `-m <mode>`: Compression mode (default 'none')
- `-a <algorithm>`: Compression algorithm (default 'snappy')
- `-r <ratio>`: Required compression ratio (default '0.875')
- `-h`: Show this help message and exit
- `-v`: Enable verbose mode

## Example Usage

```bash
# Set compression with zlib algorithm and force mode
cephos-cephfs-compression -m force -a zlib -r 0.9

# Show available modes and algorithms
cephos-cephfs-compression -m none -a snappy -r 0.875 -v
```
