# QEMU VM Launcher Script

## QEMU start

### Overview
This Bash script `qemu-start.sh` provides an automated way to create and run multiple **QEMU/KVM virtual machines** with both raw block devices (such as USB drives) and virtual disk images. It simplifies VM deployment by parsing a single configuration string that defines machine names and their associated storage devices.

The script takes care of:
- Creating persistent **qcow2 virtual hard drives** for each VM (if not already present).
- Attaching specified **raw block devices** directly to the VM.
- Assigning unique **SSH, HTTP, and VNC ports** per VM.
- Spawning multiple VMs simultaneously with proper device separation.

#### Configuration String Format
```
"name:device1,device2,...;name2:device3,device4,..."
```

- Each VM definition is separated by `;`.
- Each definition has the form:
  - `vmname:/dev/device1,/dev/device2,...`

#### Example
```bash
testing/quemu-start.sh "one:/dev/sdm,/dev/sdn;two:/dev/sdg,/dev/sdj"
```
- VM **one** will run with `/dev/sdm` and `/dev/sdn` passed through.
- VM **two** will run with `/dev/sdg` and `/dev/sdj`.
- Each VM also gets **two additional qcow2 drives** in `tmp/`.

### Port Mapping
Each VM is assigned unique ports based on its index:
- **SSH** → starts at `2200` (`2200`, `2201`, ...)
- **HTTP** → starts at `8000` (`8000`, `8001`, ...)
- **VNC** → starts at display `:10` (`:10`, `:11`, ...)

### Default Settings
- **Disk image size**: 8 GB (modifiable by editing `disk_size`).
- **VM RAM**: 8192 MB.
- **CPU cores**: 2 cores.
