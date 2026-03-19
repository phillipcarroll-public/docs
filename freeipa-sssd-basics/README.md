# freeIPA and sssd Basics

### sssd High Level

sssd: System Security Services Daemon

This is a system service that manages remote identity and authentication providers. It acts as a central intermediary between the local system and external directories like AD/LDAP/freeIPA.

- Core functions
    - Identity Mgmt
        - Retrieves user and group info (UID, GID, home dir) from remote servers and provides it to the system via the `Name Service Switch (NSS)`
    - Authentication
        - Handles login requests by verifying credentials against remote providers using `Pluggable Authentication Modules (PAM)`
    - Authorization
        - Enforce access control policies (HBAC) to determine if a valid user is allow to login to a machine

sssd also caches user creds locally providing offline authentication, this also reduces load from constant queries. a unified configuration replaces the need to configure multiple services, everything is configured from `/etc/sssd/sssd.conf`. sssd support SSO, native Kerberos support allowing users to authneticate once and access other network resources without re-authenticating.

While sssd integrates into AD I am only looking at this with the intent of freeIPA integration for centralizated management. Specifically giving users differing access to devices and some sudo access.

Main configuration: `/etc/sssd/sssd.conf`

Management tool: `sssctl` to check domain status, manage cache and tshoot.

In reference to freeIPA sssd is the primary client-side auth engine that allows the device/node to talk to freeIPA. On the client side sssd sits under the OS authentication layers, it handles the heavy auth lifts. On the server side of freeIPA sssd is used to look up users, groups etc...

When installing the freeIPA client on the client side nodes sssd is installed and configured automatically when running `ipa-client-install` after installing the `freeipa-client` package.

### freeIPA Installation

I will be installing with a fedora server vm as the freeIPA server, 4GB RAM and 4 vcpus. 

We will setup our base install with a static ip and domain set.

IP: `10.0.0.50/24`

/etc/hosts: `10.0.0.50 ipa.lab.local ipa`

If you have a firewall enabled you will need similar holes poked. For this lab I wont be running any software firewalls on the server:

```bash
sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --permanent
sudo firewall-cmd --reload
```

Update: `sudo dnf update`

Set the static ip: 

- Get the connection name
    - `nmcli connection show`
- Set the ip
    - `sudo nmcli connection modify "enp1s0" ipv4.addresses "10.0.0.50/24" ipv4.gateway "10.0.0.1" ipv4.dns "8.8.8.8" ipv4.method manual`
- Down/Up the interface
    - `sudo nmcli connection down "enp1s0"`
    - `sudo nmcli connection up "enp1s0"`

We should now have the static ip set.

Edit `/etc/hosts`: add the line `10.0.0.50 ipa.lab.local ipa`

Install freeIPA packages: `sudo dnf install freeipa-server freeipa-server-dns`

For simplicity, disable and stop firewalld: `sudo systemctl stop firewalld && sudo systemctl disable firewalld`

Verify httpd/named service is enabled and running: `sudo systemctl enable httpd named && sudo systemctl start httpd named`

Run the installer: `sudo ipa-server-install --setup-dns`

During the installer we should:

- Hostname: ipa.lab.local
- Realm Name: LAB.LOCAL
- Passwords: Set a Directory Manager password (for LDAP administration) and an IPA Admin password

NOTE: The install keeps throwing auth errors, look in the install log, fix the thing, gets to the end and still throws more errors. I dont think the above service enablements need to be done. I must have some missing steps somewhere. Pausing this for now.

### Web Management


