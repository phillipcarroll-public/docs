# Adjust TCP MSS

If you are getting high volume of tcp reassembly or unexpected slow speed with no outright networks especially on a LAN we should look at TCP.

<pcap file here>

If you look at the inbound NFS packets they are constantly being reassembled. This will increase TCP overhead and is impacting file transfers. 

This example is between two linux boxes. 

Perform a transfer and check TCP with `ss -it`

```bash
ESTAB      0           0                           10.2.96.80:912                         10.2.96.7:nfs
         bbr wscale:10,10 rto:204 rtt:0.275/0.21 ato:40 mss:1398 pmtu:1450 rcvmss:1398 advmss:1398 cwnd:156 byt                               es_sent:63224 bytes_acked:63225 bytes_received:85088 segs_out:274 segs_in:234 data_segs_out:199 data_segs_in:22                               0 bbr:(bw:466Mbps,mrtt:0.665,pacing_gain:2.88672,cwnd_gain:2.88672) send 6.34Gbps lastsnd:33404 lastrcv:33404 l                               astack:3252 pacing_rate 1.33Gbps delivery_rate 466Mbps delivered:200 app_limited busy:40ms rcv_rtt:1 rcv_space:                               19100 rcv_ssthresh:104777 minrtt:0.095
```

Looking at the mss, the max this will run is a tiny 1398. We may want to adjust the mss a bit.

```bash
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.ipv4.ip_no_pmtu_disc=0
sudo sysctl -w net.ipv4.route.flush=1
sudo sysctl -w net.ipv4.tcp_mtu_probing=1
sudo sysctl -w net.ipv4.tcp_base_mss=65483
```

This will ensure we can scale, mtu probing is on, and that we adjust the mss up.

To make this permanent there are several ways, we could simply edit the `/etc/sysctl.conf` file.

```bash
#add these lines to the bottom
net.ipv4.tcp_window_scaling=1
net.ipv4.ip_no_pmtu_disc=0
net.ipv4.route.flush=1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_base_mss=65483
```

Apply the change with `sysctl --system` as this will reload that file.

You may need to remount the NFS share again to get the new values. Retest and check `ss -it` for the new mss. If the mss is not where you expect it you may need to walk the path between devices and look for unexpected MTU settings between network devices. 
