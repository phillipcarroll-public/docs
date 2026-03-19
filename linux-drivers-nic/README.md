# Understanding Linux NIC Drivers


Training outline build on gpt-oss-20b and refined on grok. 

---

## 1 Kernel & Driver Basics (the hardware-to-OS foundation)
| #  | Topic                          | Why it matters                                      | What to do / read |
|----|--------------------------------|-----------------------------------------------------|-------------------|
| 1  | Kernel Module Loading          | Wrong driver = no link or terrible performance      | `lsmod`, `modinfo mlx5_core`, `modprobe -r` / `modprobe` |
| 2  | PCI Device Enumeration         | Confirms correct driver binding & PCIe health       | `lspci -nnk -vvv \| grep -A 20 Mellanox` (check Kernel driver, LnkCap/LnkSta) |
| 3  | Firmware Loading               | Most ConnectX bugs are firmware mismatches          | `dmesg \| grep -E 'firmware\|mlx5'`; check `/lib/firmware/mellanox/` |
| 4  | Driver Source & Options        | Understand tunable params (GSO, queues, etc.)       | `modinfo mlx5_core`; read upstream docs or `/usr/src/linux-headers-*/drivers/net/ethernet/mellanox/` |
| 5  | Kernel Config                  | Built-in vs module affects features/performance     | `grep -E 'MLX5|CONFIG_NET' /boot/config-$(uname -r)` |
| 6  | Inbox vs MLNX_OFED             | OFED gives full RDMA/RoCE features on older kernels | Compare `ofed_info` vs `modinfo mlx5_core`; know when to install MLNX_OFED |
| 7  | **Mellanox Firmware Tools (MFT)** | The vendor Swiss-army knife for config & debug     | Download MFT from NVIDIA → `./install.sh`; `mst start`; `mst status`; `mlxconfig -d /dev/mst/mt* q`; `mlxlink -d /dev/mst/mt*` |

---

## 2 Device Driver → Network Stack
| #  | Topic                          | Why it matters                                      | What to do / read |
|----|--------------------------------|-----------------------------------------------------|-------------------|
| 8  | Netdevice API (`/sys/class/net/`) | Single source of truth for interface state          | `ls -l /sys/class/net/*/device/`; queue depths, modalias |
| 9  | Interrupt Handling             | Shared IRQs or wrong affinity = drops under load    | `/proc/interrupts \| grep <iface>`; check “MSI-X” counts |
| 10 | Tx/Rx Queues & Ring Buffers    | Must match CPU cores & NUMA for line-rate           | `ethtool -l <iface>`; `ethtool -L <iface> combined 32` |
| 11 | Offload Features               | TSO/GSO/RSS/TSO crucial for GPU traffic             | `ethtool -k <iface>`; toggle and watch `dmesg` |
| 12 | Network Layer Interaction      | Correlate driver state with `ip` tools              | `ip -s link`; `ss -i`; `dmesg` correlation |

---

## 3 User-Space Configuration Layers
| #  | Topic                          | Why it matters                                      | What to do / read |
|----|--------------------------------|-----------------------------------------------------|-------------------|
| 13 | udev Rules                     | Persistent naming & permissions                     | `udevadm test /sys/class/net/<iface>`; custom PCI-based rules |
| 14 | NetworkManager vs systemd-networkd / Netplan | Conflicting managers = random failures             | Disable NM on servers: `systemctl mask NetworkManager`; use Netplan (Ubuntu) or nmcli (RHEL) |
| 15 | Netplan YAML                   | Declarative, reproducible config                    | `netplan try`; validate `/run/systemd/network/*.network` |
| 16 | systemd-networkd               | The actual applicator                               | `journalctl -u systemd-networkd -f` |
| 17 | Legacy Scripts / nmcli         | RHEL/CentOS still uses these                        | Search `/etc/sysconfig/network-scripts/`; `nmcli con show` |

---

## 4 Routing, IP Configuration & Multicast
| #  | Topic                          | Why it matters                                      | What to do / read |
|----|--------------------------------|-----------------------------------------------------|-------------------|
| 18 | IP Address Assignment          | Duplicate MACs or wrong Netplan = silent breakage   | `ip addr`; `ip -s link`; match MAC in YAML |
| 19 | ARP & Neighbor Cache           | Duplicate ARPs or stale entries kill RDMA           | `ip neigh`; `ip neigh flush all` |
| 20 | Routing Table                  | Wrong default or metric = traffic on slow path      | `ip route show table all`; `ip route get <peer>` |
| 21 | Multicast & IGMP/MLD           | NCCL/RDMA often uses multicast; drops kill collectives | `ip maddr`; `ethtool -S <iface> \| grep multi`; enable IGMP snooping awareness |

---

## 5 Advanced NIC Features & Performance (HPC-critical)
| #  | Topic                              | Why it matters                                      | What to do / read |
|----|------------------------------------|-----------------------------------------------------|-------------------|
| 22 | SR-IOV                             | Direct VF passthrough to containers/GPUs            | `echo 8 > /sys/class/net/<pf>/device/sriov_numvfs`; `ip link show` VFs |
| 23 | RDMA (verbs / RoCE / IB)           | GPU-to-GPU zero-copy (NCCL, GPUDirect)              | `ibv_devices`; `ibstatus`; `rdma link`; install `rdma-core` + perftest |
| 24 | Vendor Offloads (mlx5)             | Buggy defaults on old kernels/firmware              | `ethtool -K <iface> tso gro gso tx-checksum rx-checksum on` |
| 25 | **Link Aggregation (Bonding)**     | Redundancy + bandwidth for cluster fabric           | Netplan: `bonds: bond0: interfaces: [...] parameters: mode: 802.3ad`; `/proc/net/bonding/bond0` |
| 26 | **Jumbo Frames & Flow Control**    | 9000+ MTU + pause frames for lossless RoCE          | `ip link set mtu 9216 dev <if>`; `ethtool --show-pause`; match switch |
| 27 | **RoCE / PFC / ECN / DCQCN**       | Lossless Ethernet required for RDMA performance     | `ethtool -k <if> \| grep pfc`; dcbtool or mlxconfig; monitor CNP counters in `ethtool -S` |
| 28 | **NUMA Locality & IRQ Affinity**   | Cross-NUMA = 2–5× latency on GPU traffic            | `cat /sys/class/net/<if>/device/numa_node`; pin IRQs: `echo mask > /proc/irq/*/smp_affinity`; tune `irqbalance` or RPS/RFS (`/sys/class/net/*/queues/rx-*/rps_cpus`) |
| 29 | PCIe Topology & Link Health        | GPUs + NICs sharing lanes = bandwidth starvation    | `lspci -tvv`; confirm x16 Gen4/5 dedicated |

---

## 6 Diagnostics & Logging (your 2 AM lifeline)
| #  | Tool / Command                     | What it shows                                       | How to use |
|----|------------------------------------|-----------------------------------------------------|------------|
| 30 | `dmesg` / `journalctl -k`          | Driver/firmware/link events                         | `dmesg -T \| grep -E 'mlx5\|ConnectX\|link down'` |
| 31 | `ethtool -S <iface>`               | All error counters (drops, CRC, pause, CNP)         | Baseline before/after changes |
| 32 | `mlxlink -d /dev/mst/mt*`          | Link speed, BER, cable diagnostics                  | `-m` for module DOM info |
| 33 | `tcpdump` / `ss -m` / `cat /proc/net/softnet_stat` | Packet flows, memory pressure, softirq drops     | Capture on suspect iface |
| 34 | `journalctl -u systemd-networkd`   | Config application failures                         | Real-time with `-f` |
| 35 | `perf top -e net:*` / `bpftrace`   | Kernel hot paths under load                         | For >100 Gbps issues |
| 36 | `ip -s -s link`; `cat /proc/net/dev` | Quick aggregate stats                            | Script it |

---

## 7 System & Firmware Management (reproducibility)
| #  | Topic                              | Why it matters                                      | What to do / read |
|----|------------------------------------|-----------------------------------------------------|-------------------|
| 37 | Firmware Update (MFT)              | Fixes 90 % of “weird” issues                        | `mlxfwmanager`; `mlxconfig`; `mstflint` |
| 38 | Kernel / OFED Upgrade Path         | Newer = better RDMA & bug fixes                     | Test in VM/staging node first |
| 39 | Config Version Control             | Rollback in 30 seconds                              | Git `/etc/netplan/`, `/etc/udev/`, MFT backups |
| 40 | Hardware Inventory & Cabling       | Physical layer is root cause #1                     | Spreadsheet: MAC → PCIe slot → NUMA → cable type → switch port |

---

## 8 "Run-through” Checklist (execute in order at 2 AM)
1. `mst start && lspci -nnk \| grep Mellanox` → PCI + driver OK?  
2. `dmesg \| grep -E 'firmware\|mlx5\|link'` → firmware & init clean?  
3. `mlxlink -d /dev/mst/mt*` → link up at full speed/width?  
4. `ip link show` + `cat /sys/class/net/*/operstate` → udev/Netplan correct?  
5. `netplan apply && journalctl -u systemd-networkd -xe` → config applied?  
6. `ip addr`; `ip route`; `ip neigh` → L3 healthy?  
7. `ethtool -k <if>` + `-l` + `-S` → offloads & queues sane?  
8. MTU 9000+ and bonding if used?  
9. NUMA check: NIC & GPU on same node? IRQs pinned?  
10. RoCE/PFC counters clean?  
11. `tcpdump -i <if> -c 100` or `ib_write_bw` test if RDMA.  
12. Document everything + commit to your Git repo.

---

## 9 Suggested Learning Path (do in order)
1. Kernel basics → *Linux Kernel Module Programming Guide* + `/usr/src/linux/Documentation/networking/`
2. PCI & drivers → *Linux Device Drivers* (3rd ed.) Ch. network
3. ethtool / iproute2 → man pages + practice on a spare node
4. udev + Netplan → official docs + experiment with rules
5. RDMA & RoCE → NVIDIA RDMA/ConnectX guides + `rdma-core` tutorials
6. Performance & scaling → Kernel doc “Scaling in the Linux Networking Stack”; LWN articles on IRQ/NUMA
7. Mellanox specifics → MFT User Manual + NVIDIA Networking docs
8. Real projects → Build a 2-node RoCE cluster; intentionally break cabling/MTU/NUMA and fix with this outline

---

## 10 Final Note – “Know exactly where you are in the stack”
When `ip a` says UP but NCCL is dying:
- Driver link up? → `mlxlink` / `ethtool`
- Firmware & offloads correct? → `mlxconfig` / `ethtool -k`
- Udev/Netplan applied? → `journalctl -u systemd-networkd`
- NUMA & IRQ affinity right? → `numa_node` + smp_affinity
- MTU / PFC / RoCE lossless? → counters + switch match
- Bonding healthy? → `/proc/net/bonding/`



