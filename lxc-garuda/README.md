# Garuda - Install LXC

This is similar to my ubuntu based instructions

`sudo pacman -Syu`

`sudo pacman -S lxc bridge-utils`

### Check what lxc options are enabled

`lxc-checkconfig`

### Add lxc group

`sudo groupadd --force lxc`

`sudo usermod -aG lxc $USER`

Reboot.

### Setup the network bridge

This differs quite a bit from debian/ubuntu.

Grab your existing interface

`ip link show`

Note the interfacen name

In my example we are connected via "enp197s0"

We have to account for the auto generated Garuda interface "Wired connection 2"

Validate connection names

`nmcli connection show`

Create the bridge interface as br0

`sudo nmcli con add type bridge ifname br0 con-name br0 stp no ipv4.method auto ipv6.method ignore`

Create the slave port

`sudo nmcli con add type ethernet ifname enp197s0 con-name br0-slave-enp197s0 master br0`

Disable the logical interface

`sudo nmcli con down "Wired connection 2"`

Bring up the bridge interface

`sudo nmcli con up br0`

You should now be running on the br0 with layer 3 up and operational.

Note your macid will have changed to utilize the br0 interface so if you have DHCP reservations or anything requiring a specific MACID you will need to go update that.

We should be able to create the lxc containers and attach network to br0.

### Create LXC Containers

Garuda by default uses btrfs so we will want to flag that in the container creation. This should allow a sub volume to be created and enable better btrfs snapshotting of the guest drive.

Create an ubuntu container.

```bash
sudo lxc-create -n lab1 -t download -B btrfs -- --dist ubuntu --release noble --arch amd64 && \
sudo lxc-create -n lab2 -t download -B btrfs -- --dist ubuntu --release noble --arch amd64 && \
sudo lxc-create -n lab3 -t download -B btrfs -- --dist ubuntu --release noble --arch amd64
```

We need to create/edit the container config files.

```bash
sudo micro /var/lib/lxc/lab1/config
sudo micro /var/lib/lxc/lab2/config
sudo micro /var/lib/lxc/lab3/config
```

Edit the network conf, we need to rename the bridge interface and set the net name.

```bash
# Network configuration
lxc.net.0.type = veth
lxc.net.0.link = br0
lxc.net.0.flags = up
lxc.net.0.name = eth0
lxc.net.0.hwaddr = XX:XX:XX:YY:YY:YY

# CPU/RAM
lxc.cgroup2.memory.max = 2G
lxc.cgroup2.cpu.max = 200000 100000
```

Setting the cpu.max means it will allow 200% cpu time every 100% cpu time, or essentially using 2 full cores. Otherwise we would need to statically pin cpus. There is no soft cpu setting (ie 2 vcpu assigned to x) I have seen in lxc on arch.

Start the containers

```bash
sudo lxc-start -n lab1 -d && \
sudo lxc-start -n lab2 -d && \
sudo lxc-start -n lab3 -d
```

Check status: `sudo lxc-ls -f`

```bash
╰─λ sudo lxc-ls -f
NAME STATE   AUTOSTART GROUPS IPV4       IPV6 UNPRIVILEGED
lab1 RUNNING 0         -      10.0.0.127 -    false
lab2 RUNNING 0         -      10.0.0.124 -    false
lab3 RUNNING 0         -      10.0.0.128 -    false
```

Attach to the container: `sudo lxc-attach -n lab1`

These will not have any user accounts, its root only and no password, 
openssh-server is not installed.

### Install openssh-server

```bash
apt update -y && \
apt upgrade -y && \
apt install openssh-server micro -y
systemctl enable --now ssh
```

You will want to use your existing public key and add it to authorized keys on the guest container.

```bash
echo " " >> /etc/ssh/sshd_config && \
echo "# Enable root passwordless login" >> /etc/ssh/sshd_config && \
echo " " >> /etc/ssh/sshd_config && \
echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \

systemctl restart ssh && \

mkdir -p /root/.ssh && \
touch /root/.ssh/authorized_keys && \
echo "YOURPUBLICKEY" >> /root/.ssh/authorized_keys && \
chmod 600 /root/.ssh/authorized_keys
```

Now from your host you should be able to specify your private key that corresponds to your public key to login.

`ssh -i ~/.ssh/id_ed25519 root@10.0.0.127`

### Cloning

Now that we have 3 lab containers setup we can clone for XYZ, in this case an ansible container. 

We will clone from lab3

Stop the container: `sudo lxc-stop -n lab3`

Create the clone: `sudo lxc-copy -s lab3 -n ansible1`

If you are running a new version of lxc: `sudo lxc-copy -s lab3 -N ansible1`

Because we are running btrfs we can use the -s for cloning via snapshot.

Start the original and new container:

```bash
sudo lxc-start -n lab3 -d
sudo lxc-start -n ansible1 -d
```