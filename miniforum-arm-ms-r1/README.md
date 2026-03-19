# Setup and test Minisforum's MS-R1 ARM mini dev box.

I purchased the 64GB model with no hdd. 

Go to the Minisforum support site, search "MS-R1" and download the custom deb image. This is required in early 2026 due to this specific cpu's ARM drivers not yet making it into mainline. It is expected the kernel will have cpu/gpu drivers for this system in either 6.19 or 6.20, at that point you should be able to run any ARM distro. 

When you have the 30~GB iso downloaded you can either burn it a USB stick to live test, or burn it to an nvme. I had a spare 2TB NVME I pulled out of an older external nvme drive. Cloned and booted without issue. 

The default setup will bypass user login. The default user is `mini` and the password is `mini`. This user is part of the following:

```bash
mini@mini-localhost:~$ groups
mini cdrom floppy sudo audio dip video plugdev users netdev bluetooth
```

First thing I want to do is add a user with same / sudo access, then remove the `mini` user. 
Then add this user to sudoers, verify they have the proper desktop folders etc...

```bash
# Create the user

sudo adduser MYNEWUSER

# Add user to sudo and various groups
sudo usermod -aG sudo,cdrom,floppy,audio,dip,video,plugdev,netdev,bluetooth MYNEWUSER
```
Login as your new user and test sudo with `sudo su -l` you should login as root.

```bash
pcarroll@mini-localhost:~$ groups
pcarroll cdrom floppy sudo audio dip video plugdev users netdev bluetooth
pcarroll@mini-localhost:~$ sudo su -l
root@mini-localhost:~# exit
logout
pcarroll@mini-localhost:~$
```

All appears to be well. Lets check our partitions, I dont remember if I resized from the image during the clone or not. 

```bash
df -h

Filesystem      Size  Used Avail Use% Mounted on
udev             31G     0   31G   0% /dev
tmpfs           6.3G  3.0M  6.3G   1% /run
/dev/nvme0n1p2  1.8T   11G  1.7T   1% /
tmpfs            32G     0   32G   0% /dev/shm
tmpfs           5.0M   12K  5.0M   1% /run/lock
efivarfs        160K   14K  147K   9% /sys/firmware/efi/efivars
tmpfs           6.3G   68K  6.3G   1% /run/user/1000
tmpfs           6.3G   36K  6.3G   1% /run/user/1001
```

Yep, / has the rest of the drive available. Let's update apt, get basic tools installed and go from there.

```bash
# Set the hostname so local dns resolutions works
sudo vim /etc/hosts
# set: 127.0.1.1    pf-miniarm-01


sudo hostnamectl hostname pf-miniarm-01 && \
sudo timedatectl set-local-rtc 1 --adjust-system-clock && \
sudo timedatectl && \
sudo apt update -y  && \
sudo apt install wget curl htop openssh-server git vim dos2unix lxc lxc-templates bridge-utils -y
```

I want to setup some LXC's here which will require bridging the virtual NIC s to my physical. We will need to setup the host side bridge adapter.

```bash
# Bridge adapter setup, group and version

# Add a new lxc group and add to your user
sudo groupadd lxc
sudo usermod -aG lxc $USER

# Validate packages with
lxc-checkconfig --version
```

The MS-R1 has 2 nics and wireless/bluetooth. Lets capture the nic we will used to create the new bridge.

`ip a` and grab the interface you are connected to, in our case `eth1`.

It looks like this build does not have netplan installed. Lets install netplan:

```bash
sudo apt install netplan.io -y
sudo systemctl unmask systemd-networkd.service
sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-networkd.service
sudo systemctl mask networking.service
```

Lets create out netplan:

```bash
sudo vim /etc/netplan/01-netcfg.yaml
```

Add the basic config for the bridge int using our selected `eth1` interface.

```yaml
network:
  version: 2
  ethernets:
    eth1:
      dhcp4: true
  bridges:
    br0:
      interfaces: [eth1]
      dhcp4: yes
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```

Apply with: `sudo netplan apply`

Dont panic, you will lose connectivity if you are doing this over ssh. We just swapped over to using our virtual bridge interface to pull DHCP, it has a differnt MACID than our physical eth1 and thus will pull a different IP.

Looks like I have a new lease on my Fortinet for 3 minutes: 10.0.0.129

Yep, thats it we are back in:

```bash
Last login: Sat Jan 31 13:41:41 2026 from 10.0.0.100
pcarroll@pf-miniarm-01:~$
```

We now need to validate our active network conf with `ip a`

```bash
: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
link/ether f6:ec:17:9e:95:54 brd ff:ff:ff:ff:ff:ff
inet 10.0.0.129/24 metric 100 brd 10.0.0.255 scope global dynamic br0
valid_lft 86221sec preferred_lft 86221sec
inet6 fe80::f4ec:17ff:fe9e:9554/64 scope link
valid_lft forever preferred_lft forever
```

I'm pretty confident at this point the things I need are going to work. Before I go any further I want to remove the `mini` user:

We have a couple issues, the desktop side of this OS is set by Minisforum to autologin which I dont want or need.

```bash
# Disable lightdm's autologin, this isnt the default but JIC

sudo vim /etc/lightdm/lightdm.conf

# Comment out:
# autologin-user=root
# autologin-user-timeout=0
```

```bash
# Disable Gnome's autologin, this is default on the deb install

sudo vim /etc/gdm3/daemon.conf

#AutomaticLoginEnable = True
#AutomaticLogin = mini
```

As a test I have rebooted and validated that the `mini` user no longer automatically logs on with: `who` after logging in my new admin user.

```bash
pcarroll@pf-miniarm-01:~$ who
pcarroll pts/0        Jan 31 14:20 (10.0.0.100)
```

Now that the mini user is no longer logging into Gnome automatically as admin, lets remove it.

```bash
# Remove mini factory username/pass
sudo deluser --remove-home mini
```

Now I did not check if there was some custom foo associated with that user regarding services or some needed wackyness. I'm just going to reboot again and validate my basic things work fine.

All checked out, nothing funky.

After some playing around I added the `eth0` to our bridge, I only plug one in at a time so the lack of spanning-tree does not pose much risk. 

```yaml
# Updated netplan
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
    eth0:
      dhcp4: true
  bridges:
    br0:
      interfaces: [eth0, eth1]
      dhcp4: yes
      optional: true
      parameters:
        stp: false
        forward-delay: 0
```

Apply: `sudo netplan apply`

Now lets disable the wireless adapter `wlan0`

Lets take the systemd approach:

```bash
sudo vim /etc/init.d/disable-wlan0.sh

# in that shell script
#!/bin/sh
/sbin/ip link set wlan0 down

# Make that sh executable
sudo chmod +x /etc/init.d/disable-wlan0.sh

# Add to startup
sudo update-rc.d disable-wlan0.sh defaults
```

At this point we are good to go to create containers, install ansible etc... This was not meant as a guide just kind of rambling along as I unboxed this thing, got it going on a Friday night. 10/10 for basic ubuntu/deb experience, I did not have to change anything there. I dont plan to do to much with the box other than use it as a lab device and maybe dabble in some ARM64 assembly at some point.

Not sure when/how ping got messed up but it appears we lost perms to ping...

```bash
# Login as root and reset perms

sudo su -l
sudo chmod u+s /bin/ping
sudo chmod u+s /usr/bin/ping
```

## Validate box is ready for ARM64 assembly coding/compiling

Verify we have these packages installed:

```bash
which as
which ld
which objdump
apt list | grep "binutils"
```

It looks like this custom deb came with everything needed for basic arm64 assembly. 

Create a test file: `vim hello.s`

Add a hello world program to the file:

```asm
.global _start

_start:
    mov x0, #1          // stdout file descriptor
    ldr x1, =msg        // address of message
    mov x2, #13         // message length
    mov x8, #64         // syscall: write
    svc #0              // invoke syscall

    mov x0, #0          // exit code
    mov x8, #93         // syscall: exit
    svc #0              // invoke syscall

msg:
    .ascii "Hello, World\n"
```

Assemble the file: `as -o hello.o hello.s`

Make it executable: `ld -o hello hello.o`

Test the executable: `./hello`

```bash
pcarroll@pf-miniarm-01:~$ mkdir asm-test
pcarroll@pf-miniarm-01:~$ cd asm-test/
pcarroll@pf-miniarm-01:~/asm-test$ mkdir hello-test
pcarroll@pf-miniarm-01:~/asm-test$ cd hello-test/
pcarroll@pf-miniarm-01:~/asm-test/hello-test$ vim hello.s
pcarroll@pf-miniarm-01:~/asm-test/hello-test$ as -o hello.o hello.s
pcarroll@pf-miniarm-01:~/asm-test/hello-test$ ld -o hello hello.o
pcarroll@pf-miniarm-01:~/asm-test/hello-test$ ls
hello  hello.o  hello.s
pcarroll@pf-miniarm-01:~/asm-test/hello-test$
pcarroll@pf-miniarm-01:~/asm-test/hello-test$ ./hello
Hello, World
```

This appears to work just fine, or at least good enough to dabble in some arm64 assembly.
