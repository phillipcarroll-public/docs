# LXC Basic Flow

### Install

```bash
sudo apt update -y
sudo apt install lxc lxc-templates bridge-utils

# Create the lxc group
sudo groupadd lxc
# Add yourself to the group
sudo usermod -aG lxc $USER
```

- lxc = core package
- lxc-templates = templates for different distros
- bridge-utils = setup bridging to connect vm to local net L2 adjacent

Validate with:

```bash
lxc-checkconfig --version
```

### Prep Our Network

We need to edit netplan so we can hang lxc interfaces off a bridge attached to our physical eno2 10Gi nic. 

Base setup:

```bash
network:
  version: 2
  ethernets:
    eno2:
      dhcp4: true
```

We need to move to:

```bash
network:
  version: 2
  ethernets:
    eno2:
      dhcp4: true
  bridges:
    br0:
      interfaces: [eno2]
      dhcp4: yes
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```
This will slave our physical 10Gi eno2 to the br0 interface and later allow us to hang lxc interfaces off of it to receive DHCP on our LAN.

### Create Some Containers

This will configure the containers and setup conf files and such.

```bash
sudo lxc-create -n lab1 -t download -- --dist ubuntu --release noble --arch amd64 && \
sudo lxc-create -n lab2 -t download -- --dist ubuntu --release noble --arch amd64 && \
sudo lxc-create -n lab3 -t download -- --dist ubuntu --release noble --arch amd64
```

### Configure The Containers

```bash
sudo micro /var/lib/lxc/lab1/config
sudo micro /var/lib/lxc/lab2/config
sudo micro /var/lib/lxc/lab3/config
```

Replace the network configuration in those files (at the bottom) with:

```bash
lxc.net.0.type = veth
lxc.net.0.link = br0
lxc.net.0.flags = up
lxc.net.0.name = eth0

# CPU/RAM
lxc.cgroup2.memory.max = 2G
lxc.cgroup2.cpuset.cpus = 0-1
```

### Start Containers

```bash
sudo lxc-start -n lab1 -d
sudo lxc-start -n lab2 -d
sudo lxc-start -n lab3 -d
```

### Verify And Connect

Check status: `sudo lxc-ls -f`

You should see these containers on your local network.

Attach to a container on console to setup ssh/etc...: `sudo lxc-attach -n lab1`

Validate you can ping outbound to the internet or if its in an air-gapped environment that is still routable it can reach paste the gateway.

### Stop or Destroy

Stop: `sudo lxc-stop -n lab1`

Destroy: `lxc-destroy -n lab1`

### Storage

Lxc containers are persistent by default so as long as the virtual drive is not corrupted or destroyed just treat it like any other VM.

### Scripts

Check status on multiple containers

This one is kinda useless but if you are thinking in terms of just using bash scripts to help admin containers this is aligned.

```bash
#!/bin/bash

sudo lxc-ls -f
```

Start multiple containers

```bash
#!/bin/bash

containers=("ans-ctrl-01" "ans-drone-01" "ans-drone-02" "ans-drone-03")

for container in "${containers[@]}"; do
	echo "Starting container: $container"
	sudo lxc-start -n "$container" -d
done
```

Stop multiple containers

```bash
#!/bin/bash

containers=("ans-ctrl-01" "ans-drone-01" "ans-drone-02" "ans-drone-03")

for container in "${containers[@]}"; do
	echo "Stopping container: $container"
	sudo lxc-stop -n "$container"
done
```

Destroy muiltiple containers

```bash
#!/bin/bash

containers=("ans-ctrl-01" "ans-drone-01" "ans-drone-02" "ans-drone-03")

for container in "${containers[@]}"; do
        echo "Stopping container: $container"
        sudo lxc-stop -n "$container"
done

for container in "${containers[@]}"; do
	echo "Destroying container: $container"
	sudo lxc-destroy -n "$container"
done
```

Create and configure multiple containers

```bash
#!/bin/bash

containers=("ans-ctrl-01" "ans-drone-01" "ans-drone-02" "ans-drone-03")
macids=("ea:a7:c8:31:28:c8" "5a:d6:43:d1:85:de" "4a:ba:be:44:5c:7a" "ae:a9:c2:76:a8:7a")

# !containers so it using the indices
for i in "${!containers[@]}"; do
        container="${containers[i]}"
        macid="${macids[i]}"
        #
        echo "Creating container: $container"
        sudo lxc-create -n "$container" -t download -- --dist ubuntu --release noble --arch amd64
        #
        sleep 3
        #
        echo "Updating config file for: $container"
        echo " " | sudo tee /var/lib/lxc/"$container"/config > /dev/null
        echo "# Distribution configuration" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.include = /usr/share/lxc/config/common.conf" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.arch = linux64" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo " " | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "# Container specific configuration" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.apparmor.profile = generated" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.apparmor.allow_nesting = 1" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.rootfs.path = dir:/var/lib/lxc/$container/rootfs" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.uts.name = $container" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo " " | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        #
        echo "# Network configuration" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.net.0.type = veth" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.net.0.link = br0" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.net.0.flags = up" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.net.0.name = eth0" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.net.0.hwaddr = $macid" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo " " | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "# CPU/RAM" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.cgroup2.memory.max = 2G" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
        echo "lxc.cgroup2.cpuset.cpus = 0-1" | sudo tee -a /var/lib/lxc/"$container"/config > /dev/null
done
```
