#!/bin/bash

containers=("app1" "app2" "db")
macids=("a2:01:01:01:01:a1" "a2:01:01:01:01:a2" "a2:01:01:01:01:db")

# !containers so it uses the indices
for i in "${!containers[@]}"; do
	container="${containers[i]}"
	macid="${macids[i]}"
	#
	echo "Creating container: $container"
	sudo lxc-create -n "$container" -t download -- --dist debian --release bookworm --arch arm64
	#
	sleep 1
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
