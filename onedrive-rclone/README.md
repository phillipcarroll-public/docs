# OneDrive Setup Linux

Tested on Garuda Desktop (ARCH) Kernel 6.18 zen

Create a folder where we will mount VFS: `mkdir ~/OneDrive`

Install rclone: `sudo pacman -S rclone` or `sudo apt install rclone -y`

rclone will allow us to use our OneDrive share/account and mount it via VFS.

Loose steps as you walk through the rclone config menu. The ID of objects in this menu changes over time so be looking for the right thing before you enter a number in. 


```bash
rclone config

n # for new remote

OneDrive # name of remote

# This may bring up a search, look for Microsoft OneDrive, grab the number

38 # number of OneDrive service as of late 2025

# Press Enter through client_id, client_secret

1 # This should be Microsoft Cloud Global

n # to Advanced config

y # to auth through browser

# Login to MS account browser popup

1 # to select Onedrive Personal

1 # to select personal

yes

yes # to keep remote, otherwise it wipes OneDrive

q # to close config
```

We could run: `rclone --vfs-cache-mode writes mount OneDrive: ~/OneDrive &` and it will work but lets make it a service so it run at login.

Create a new service: `micro /etc/systemd/system/onedrive.service`

Paste the following:

```bash
[Unit]
Description=OneDrive over rclone Daemon
After=network-online.target
Wants=network-online.target

[Service]
User=pcarroll
Type=simple
ExecStart=/usr/bin/rclone --vfs-cache-mode writes mount OneDrive: /home/pcarroll/OneDrive/ --config /home/pcarroll/.config/rclone/rclone.conf
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

This service will run as our user on our account.

We need to: 

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable onedrive.service && \
sudo systemctl start onedrive.service && \
sudo systemctl status onedrive.service
```

Your OneDrive should now be showing in ~/OneDrive

Remember, this isn't Windows, your editing live files in the MS Datacenter and not a local copy. If you need a local copy you need to edit the installation or simply copy the files locally.
