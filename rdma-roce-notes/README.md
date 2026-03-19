
## RDMA (Remote Direct Memory Access)

Share the resources.

RDMA is just a concept, the specifics are in the implementation (Infiniband, RoCE etc...).

- Direct memory access between systems over a network
- No CPU, Kernel involvement which reduces overhead and latency
- HPC, AI, DB, Storage
- Zero-Copy
    - Data moves directly between memory regions
        - Think of a memory region as a pointer to a large block of memory managed by the RDMA request receiver
            - A contiguous block of RAM
        - This is all defined by the receives OS which manages the memory regions
    - Zero-Copy is just the non-requirement of the RDMA sender needing to copy data from its RAM to the receivers RAM, and vice-versa
        - There is no copying of data back and forth

## RoCE (RDMA over Converged Ethernet)

Transport the resources.

- Runs over Ethernet
- UDP Transport
- Highly structured queuing
    - **Note:** This is probably a performance item to monitor, things stuck in queues = data death
    - Two main queue types
        - CQ (Completion Queue)
            - Sender maintained
            - This is a list of all RDMA operations to be performed
            - When there is an ACK from the receiver the completion notification is pushed onto the CQ
            - CQ Tagging is provided to switches so they are aware of RoCE/RDMA traffic for priority queuing/QoS etc...
                - This CQ tag is added to the UDP header and NOT Layer 2
        - BCQ (Background Completion Queue)
            - Receiver maintained
            - The goal here is to proactively send completion notifications before the sender requests them to reduce/eliminate latency
    - RoCE has built in mechanisms for congestion control
    - RoCE works along side Flow Control

### This is where RDMA/RoCE differ from most all network/transport protocols

When the switch environment/fabric is configured it will look for CQ tags in the UDP header and for the most part L2 headers remain all unchanged. This is functionally different than most transport technologies. RoCE header flags and CQ Tagging is all Layer 4, however, a switch participating in RoCE will scan the L4 UDP header in the L2 payload to determine RoCE flags/options/tagging etc...

#### CQ Tag Administration

These are not automatically assigned. CQ tags are typically created when setting up RoCE v2 on a server (non-transiting device) interface. 

CQ tags are a 64bit `wr_id` tag set by the requesting application. If the application does not set the `wr_id` then typically `libibverbs` will assign default tags or incremental tags, however this is not common.

Tags are unique per QP (Queue Pairs). A QP is 2 queues within a NIC used as a send/receive RDMA pair. A NIC may have multiple QP's. Each QP has independent congestions and flow control capabilities. This is specific to RoCE v2. 

- CQ tags do not need to be unique across different QP's on the same server
- CQ tags do not need to be unique across different interfaces of servers
- CQ tags are locally significant only to the QP, very small scope

Engineers do not coordinate tags, this should be 100% handled by the application. However, engineers do manage the configuration of QPs and CQs via system parameters as needed.

In `/etc/modprobe.d/mlx5.conf` you could add specifics `options mlx5_core log_num_qps=7 log_num_cqs=7`

#### CQ Monitoring

- `ibv_cq_poll` Verbs API function to poll completeion queue for work requests
    - via `perftest`
- `rdma-tool` CLI utility for managing/monitoring resources (CQ, QP, Links) and inspecting state of devices
    - via `rdma-core`
- `dmesg | grep rdma` Log messages filtered for RDMA

#### RoCE v1 vs RoCE v2

Right off the bat, RoCE v2 supports routing data which makes it highly scalable.

| Feature | RoCE v1 | RoCE v2 |
|------------------------------|------------------------------|------------------------------|
| **Congestion Control**|  Static Rate (Rate-Based) | Dynamic Rate (ECMP/ECMP-B) |
| **ECMP Support** | No | Yes (ECMP-B: Enhanced Congestion Management) |
| **Prioritization** | Lower | Higher |
| **Scalability** | Limited | Significantly Improved (L3) |
| **Performance** | Good for smaller networks | Optimized for larger networks |
| **Switch Support** | Requires specific switch features | More broadly supported |

#### RoCE v2 ECMP-B

- ECMP-B is real-time congestional control
- Adaptive sending rates based on congestion
- Receiver initiates rate adjustments
- Bi-Di communication, the receiver can tell the sender to ramp up/down
- Lower packet loss than other congestion control mechanisms
- Anticipates congestion before it occurs
- Receiver estimates its own processing capability and sends info to Sender

#### ECMP-B Messaging

- ECMP-B firsts sets a baseline sending rate based on link size
    - This is then dynamically adjusted on the fly
- Congestion messages over ethernet
    - Rate-Response Messages
    - Capacity
    - Request Rate
    - Congestion Feedback
    - Rate Adjustment
- ECMP-B Messaging are inserted into the L4 UDP header
    - L2 Ethernet headers are not modified for congestion notifications
    - Network congestion looks like it self-contained between hosts via ECMP-B

#### RoCE Modules

- Kernel Modules
- Manage hardware (e.g., NICs), enforce RoCE protocol (e.g., UDP/IP encapsulation for v2), and handle QP/CQ operations
    - `rdma_cm`: Manages RDMA connection establishment (e.g., setting up Queue Pairs over RoCE)
    - `rdma_ucm`: Provides user-space access to RDMA connection management
    - `ib_core`: Core RDMA functionality, managing Queue Pairs (QPs), Completion Queues (CQs), and Memory Regions (MRs)
    - `ib_uverbs`: Interfaces between user-space applications and kernel RDMA operations
    - `ib_umad`: Supports RDMA management datagrams for device control
    - `iw_cm`: Handles iWARP (if applicable, though RoCE-specific in some contexts)
    - `rpcrdma`: Supports RDMA for NFS (optional, not RoCE-specific)

- NIC-Specific Modules
- Translate RDMA commands into hardware operations, ensuring RoCE packets are sent over Ethernet
    - For Mellanox NICs: mlx5_core (hardware driver) and mlx5_ib (RDMA support)
    - For Broadcom: bnxt_en and bnxt_re (RDMA extensions)

- User-Space Modules/Libraries (APIs)
- Allow applications to post Work Requests, poll CQs, and manage RDMA resources
    - `libibverbs`: Core user-space library for RDMA operations (e.g., ibv_post_send, ibv_poll_cq).
    - `librdmacm`: Connection management library for establishing RoCE connections.
    - `perftest`: Tools like ib_send_bw for testing RoCE performance (uses libibverbs).

#### RoCE Memory Addressing

RoCE uses Memory Regions (MRs) and Memory Keys to manage memory addressing

- Memory Region (MR): A contiguous block of memory on a host, registered with the RDMA NIC. The NIC uses this registration to map virtual addresses to physical memory for direct access
- Memory Keys: Each MR is associated with two keys:
    - Local Key (LKey): Used by the local RDMA NIC to access the MR for operations like sending data
    - Remote Key (RKey): Shared with a remote host to allow it to directly read from or write to the MR

Memory is explicity registered via the application using `ibv_reg_mr`, this is not automated. The key exchange is done out of band in the control plane. The application also control access to specific items via permissions.

Once the MR (memory region) is is registered the NIC handles the address translation automatically. The NIC will also handle remote key validation.

#### RDMA Memory Types

Byte-Swapped

- Data is explicitly converted before storage or transmission
- Little endian to big endian or big endian to little endian
- RDMA assumes an application or something like middleware is handling the translation, RDMA just moves the data
- Heterogeneous systems (A TO B)

Unswapped

- Data is stored in the native endian
- RDMA assumed the sender and receiver are using the same endian or that conversion happens at another layer
- Homoegenous systems (A TO A)

Endian Examples

How are the bytes written in the memory block? Left to Right or Right to Left?

- Big Endian (Left to Right)
- 2 byte chunk 
    - Binary 1111111100000000
    - Hex 0xFF00
    - 65280 Unsigned 16bit Int

- Little Endian (Right to Left)
- 2 byte chunk
    - Binary 0000000011111111
    - Hex 0X00FF
    - 255 Unsigned 16bit Int

#### Typical Switch Interface Configuration Examples:

**Note:** This is just interface examples, there will be high/global settings that must be configured on each switch.

**Cisco (Conceptual - Requires specific switch models and RoCE modules):**

```
interface Ethernet1/1
  description RoCE Interface
  roce rx-cq-tag 0x10
  roce tx-cq-tag 0x10
  roce rx-rate-response-interval 100  // Adjust based on application
  roce tx-rate-response-interval 100
```

**Juniper (Conceptual - Requires specific switch models and RoCE modules):**

```
set interfaces ge-0/0/0 type roce
set roce interfaces ge-0/0/0 qos roce-qp id 1
set roce interfaces ge-0/0/0 rx-qp-size 64  //Example Size
```

**Dell EMC (Conceptual - Requires specific switch models and RoCE modules):**

```
interface Ethernet1
  port-mode roce
  roce-rx-cq-tag 0x10
  roce-tx-cq-tag 0x10
```

**HP Aruba (Conceptual - Requires specific switch models and RoCE modules):**

```
interface GigabitEthernet1/0/1
  mode roce
  rx-cq-tag 0x10
  tx-cq-tag 0x10
```

**Arista Networks (Conceptual - Requires specific switch models and RoCE modules):**

```
interface Ethernet1
  port-mode roce
  rx-cq-tag 0x10
  tx-cq-tag 0x10
```
