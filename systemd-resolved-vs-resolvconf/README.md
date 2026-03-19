# systemd-resolved vs resolvconf | openresolv

**NOTE:** Specific to Ubuntu 24.04 LTS

### systemd-resolved

- `systemd-resolved`
    - part of systemd
    - symlink to
        - `/run/systemd/resolve/stub-resolver.conf` or
        - `/run/systemd/resolve/resolv.conf`
    - DNS resolution using stub resolver `127.0.0.53`
    - Built in DNS caching
    - DNSSEC is supported
    - Split DNS / per-interface DNS is supported
    - mDNS / LLMNR supported
    - Default in Ubuntu

### resolvconf | openresolv

- `resolv.conf`
    - part of `openresolv` or `resolvconf` packages
    - directly manages `/etc/resolv.conf`
        - overwrites `/etc/resolv.conf` with an actual file, no symlink
    - DNS resolution is done by whatever is configured in the conf
    - no DNS caching
    - Passed DNSSEC flags if configured but no local validation
    - limited split DNS / per-interface support
    - no mDNS / LLMNR support
    - Not default, legacy support
    - Not installed by default

Both work by way of `/etc/resolv.conf` with the major difference with systemd-resolved backending that conf file by setting the stub resolver to 127.0.0.53:53.

**systemd-resolved** can be managed with `resolvectl` or by editing `/etc/systemd/resolved.conf` or... if you want to setup a perlink dns resolution simply setup per link DNS in `netplan`.

Example of `resolvectl`

```bash
resolvectl status                  # show current DNS settings per interface
resolvectl dns eth0 8.8.8.8 1.1.1.1   # set global or per-interface DNS
resolvectl domain eth0 ~.         # enable split DNS / DNS-over-TLS, etc.
systemctl status systemd-resolved
```
