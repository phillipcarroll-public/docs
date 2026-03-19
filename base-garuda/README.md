# Garuda Base Build and Basic Notes

I have spent 95% of my linux time in ubuntu/debian based distros and 5% in fedora. I moved my desktop to Garuda which is arch based. This is just some general notes getting Garuda setup on 6.17.6.

System: 

- Minisforum AI X1 Pro
    - Ryzen 9 AI HX 370 12 Core (4p|8e) 24 Threads
    - 96GB RAM
    - 890M iGPU 16GB
    - 4TB x 3 NVME
        - 2 @ Pcie 4.0 x4
        - 1 @ Pcie 4.0 x1

Grab the pcie topology: `lstopo`

lstopo will give you a nice visual representation of your hardware layout which includes a clear mapping of pcie to block device. 

Get the NVME pcie IDs and speeds: `sudo lspci -vv | more`

Look at the Link Status for each of your NVMEs

- c1:00.0
    - LnkSta: Speed 16GT/s, Width x4
    - nvme0n1
- <span style="color: red;">c2:00.0</span>
    - <span style="color: red;">LnkSta: Speed 16GT/s, Width x1</span>
    - <span style="color: red;">nvme1n1</span>
- c6:00.0
    - LnkSta: Speed 16GT/s, Width x4
    - nvme2n1

Now lets determine what drive we installed our OS on...

```bash
╰─λ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
...
...
nvme1n1     259:0    0  3.7T  0 disk
├─nvme1n1p1 259:5    0  300M  0 part /boot/efi
├─nvme1n1p2 259:6    0  3.6T  0 part /var/tmp
│                                    /var/log
│                                    /home
│                                    /var/cache
│                                    /srv
│                                    /root
│                                    /
...
...
```

<span style="color: red;">Yep, we 100% installed the OS on nvme1n1 running on 1 lane of Pcie 4.0.</span> We can just simply move the nvme over to physical slot 0 or 1. I do not have any performance issues as we should still be running roughly 2GB a sec but since we paid for the speed...

Physical slot 0 and 2 were swapped so we should now be in an x4 slot. Running the same checks as above:

Get the NVME pcie IDs and speeds: `sudo lspci -vv | more`

- c1:00.0
    - LnkSta: Speed 16GT/s, Width x4
    - nvme0n1
- c2:00.0
    - LnkSta: Speed 16GT/s, Width x1
    - nvme1n1
- c6:00.0
    - LnkSta: Speed 16GT/s, Width x4
    - nvme2n1

Check: `lsblk`

And yes now we are running on: nvme0n1

...moving on :)

Add other drives for our additional fast/slow storage.

I dont typically use a good deal on my boot drives, but I can fill up other drives depending on the current projects (ie video editing or hoarding some sort of ISOs or large VMs, or dual boot into windows/other distros

boot drive: nvme0n1
slow drive: nvme1n1
fast drive: nvme2n1

Use KDE Partition Manager, sanitize fast/slow drives.

Use entire drive space, btrfs for filesystem. Create a folder in `/mnt/stor` and mount to that folder. 

We will leave nvme2n1 alone for now as we may install other distros etc...

### Garuda - System Setup Assistant

Items to check in System - > Setup Assistant

- OS Preferences
    - Printer
    - Wallpapers
- Software centers
    - Appimage
    - Octopi
    - Bazaar
- Office
    - LibreOffice Fresh
- Internet
    - Qbittorrent
- Audio
    - Audacity
- Video
    - Shotcut
    - Kdenlive
    - OBS Studio
- Graphics
    - GIMP
- Development
    - Docker
    - VSCode (proprietary)
    - VSCodium
- Virtualization
    - GNOME Boxes
    - Virt-manager

### Garuda - Discover

Use Discover to install: shotcut

### Set Time

```bash
sudo timedatectl set-local-rtc 1 --adjust-system-clock
sudo timedatectl
```

### Garuda - Apt Update/Upgrade Equivalent

```bash
sudo pacman -Syu
```

### Garuda - No SSH server by default

```bash
sudo pacman -S openssh

sudo systemctl start sshd.service
sudo systemctl enable sshd.service
sudo systemctl status sshd.service
```

### Garuda - Install apps (outside of ssh/lxc)

```bash
sudo pacman -S ffmpeg psensor steam qmmp lact btop vim
```

```bash
yay -S microsoft-edge-stable-bin
```

### Garuda - Remove an app

Removes package and conf

```bash
sudo pacman -Rn mybadapp
```
Removes package, conf and orphaned dependencies

```bash
sudo pacman -Rns mybadapp
```

### Garuda - Check installed apps

Removes package and conf

```bash
sudo pacman -Qe
```

### Garuda - Firedragon Browser

- about:config
    - browser.tabs.loadDivertedInBackground
        - set to false

### Garuda - Ollama Install

Install: `curl -fsSL https://ollama.com/install.sh | sh`

Create a shell script to pull models:

```bash
#!/bin/bash

ollama pull qwen3-next:80b-a3b-thinking && \
ollama pull gpt-oss:20b && \
ollama pull gpt-oss:120b && \
ollama pull llama4:latest && \
ollama pull nemotron-3-nano:latest && \
ollama pull gemma3:27b-it-q4_K_M && \
ollama pull phi4-reasoning:plus
```

When running models tag `--verbose` for stats.

### Garuda - Display Configuration

- 1080p
- Scale: 100%
- 240hz
- Enable HDR and calibrate
- Uncheck Screen Tearing Allowed in Fullscreen windows

In the "Screen Edges" tab we need to turn down the activation delay significantly.

Set to: 

- Activation Delay: 150ms
- Reactivation Delay: 350ms

Note these timers also changes how the top bar and bottom dock responds.

### Garuda - Window Decorations

Open system settings and search for "Window Decorations"

We should have "Sweet-Dark" set by default. Click the edit icon.

Click the 3 dot hamburger in the upper right "More Actions" then select "Configure Titlebar Buttons"

We should now drag the Min Max Close icons to the right of the spacer. You drag it in the virtual taskbar and not the large icons in the center. Those icons are the raw materials to build the bar, not represetative of the bar itself. 

### Configure Psensor

Pretty simple, just open, and edit "Sensor Preferences"

You will need to map the pcie ids to nvme's, the rest is very self explanatory.

### Validate Sleep/Wake

Validate that sleep/wake works.

### Python Venv and Youtube Downloader

Create a venv folder: `mkdir ~/venv && cd ~/venv`

Create a general cpu environment: `python -m venv cpu`

Activate the venv: `source  cpu/bin/activate.fish`

Install the yt-dlp package: `pip install yt-dlp`

### Using yt-dlp

music.sh script

```bash
#!/bin/bash

# yt-dlp should already be installed but if now
#pip install yt-dlp
# https://github.com/yt-dlp/yt-dlp

# -P "download/folder/here"
# -x download audio only
# --audio-format mp3 ... the audio format
# for video ommit -x and --audio-format
# Limit speed with -r 800K, -r 2MB etc... to mitigate temporary ban
# Sleep a bit between downloads

# Mostly electronic background music

#yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=IdoWuiCfZoE && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=i69_gWvFH3A && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=P0NWROAgL94 && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=T2QZpy07j4s && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=4cEKAYnxbrk && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=vhbVKJbccz4 && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=1nd1T44tBkk && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=zIQr6P100dw && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=2HtToGzNo24 && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=V98I19bLr-o && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=qUundAa9j4M && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=u8sn9C3sID0 && \
sleep 10 && \
yt-dlp -P "~/Music" -r 800K -x --audio-format mp3 https://www.youtube.com/watch?v=mA6XdqRUOGw
```

### Add OpenCL for Intel ARC GPU

If needed:

```bash
sudo pacman -S intel-compute-runtime ocl-icd && \
sudo gpasswd -a $USER render && \
newgrp render
```
