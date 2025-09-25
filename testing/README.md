# QEMU VM Launcher Script

## QEMU network

This script `quemu-network.sh` simplifies the setup and teardown of a **network bridge** for QEMU virtual machines on a Debian (or other Linux) host.
It creates a bridge interface, attaches the host's primary network interface to it, and handles TAP interfaces used by QEMU guests.

- Run the script **before launching QEMU VMs** (`qemu-start.sh`) that require bridged networking.
- Bridge name is fixed as `br_qemu`.
- TAP interfaces automatically get prefix `tap_qemu`.
- A persistent MAC for the bridge (`02:11:00:22:44:01`) is set for stability.
- Script assumes at least one DHCP client (`dhcpcd` or `dhclient`) is installed.
- You may adapt the script to your interface names and preferred DHCP client.

### Features

- Creates and removes a Linux bridge (`br_qemu`) for QEMU networking.
- Moves the host's master interface (e.g. `eth0`) into the bridge.
- Supports multiple TAP interfaces for VMs (with prefix `tap_qemu`).
- Restores the network configuration when tearing the bridge down.
- Requests a new IP address automatically after changes (supports `dhcpcd` and `dhclient`).

### Requirements

- `iproute2` package (`ip` command)
- Either `dhcpcd` or `dhclient` must be installed for IP address management
- Root privileges are required (e.g. run with `sudo`)

### Usage

```bash
./qemu-bridge.sh -m <mode> -i <interface>
```

#### Options

| Option | Argument      | Description                                     |
|--------|--------------|-------------------------------------------------|
| `-m`   | `up`/`down`  | Work mode. Use `up` to create the bridge, `down` to tear it down. |
| `-i`   | interface    | Host's primary network interface (e.g. `eth0`). |
| `-h`   | none         | Show usage help. |

#### Examples

**Bring bridge up:**

```bash
sudo ./qemu-network.sh -m up -i eth0
```

This will:
- Create a bridge `br_qemu`
- Move `eth0` into the bridge
- Bring everything up
- Request a new IP address for the bridge

**Tear bridge down:**

```bash
sudo ./qemu-network.sh -m down -i eth0
```

This will:
- Detach `eth0` from the bridge
- Delete TAP interfaces (`tap_qemu*`)
- Remove the `br_qemu` bridge
- Re-request an IP address for `eth0`


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
./run_vms.sh "one:/dev/sdm,/dev/sdn;two:/dev/sdg,/dev/sdj"
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
