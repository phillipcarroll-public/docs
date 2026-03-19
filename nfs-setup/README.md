# Base Ubuntu NFS Setup

From a fresh vm clone, we will add an additional 20gb "scsi" drive to be used for nfs things. This should show up as `sdb`

Change the hostname: `sudo hostnamectl hostname nfs-1-lab`

Source bash or log in again to get the new hostname.

Update apt: `sudo apt update -y && sudo apt upgrade -y`

Install nfs: `sudo apt install nfs-kernel-server -y`

We need to setup the `sdb` drive in prep for mounting and exporting. 

Check `lsblk` and validate `sdb` is not in use. If it is in use we need to sanitize the drive:

```bash
# Assuming /dev/sdb

# Wipe all signatures
sudo wipefs -af /dev/sdb

# Create 1 large gpt primary partition
sudo parted /dev/sdb mklabel gpt
sudo parted /dev/sdb mkpart primary ext4 0% 100%
# Set lvm off
sudo parted /dev/sdb set 1 lvm off

# Create ext4 file system on sdb1
sudo mkfs.ext4 -L nfsdata /dev/sdb1
```

At this point we should have a useable drive, albeit unmounted drive on /dev/sdb1. We need to determine where we will mount this drive, grab the UUID, and setup FSTAB to make this reboot survivable.

```bash
# Grab a copy of the drives UUID, we will need this for FSTAB
sudo blkid /dev/sdb1

# Create a /export folder, it can be anything but we will use this as our example
sudo mkdir -p /export
```
We need to edit FSTAB and add our drive/UUID: `sudo nano /etc/fstab`

**UUID**: `fb13c0bc-6888-4b02-b83b-7b414e49acce`

Add the following line to FSTAB:

```bash
UUID=fb13c0bc-6888-4b02-b83b-7b414e49acce   /export   ext4   defaults,noatime   0 2
```

Save and exit `/etc/fstab`

We need to mount and verify:

```bash
sudo mount -av
# You may also need to run: systemctl daemon-reload
df -h /export
lsblk
```

We should now see the /export folder mounted to /dev/sdb1. Next we need to setup the data folder which will be used by nfs.

```bash
# Create the data folder
sudo mkdir /export/data

# nobody:nogroup is a placeholder with min priv/access
sudo chown nobody:nogroup /export/data   # safest for NFS
# Owner has full access, others have read/exec access
sudo chmod 755 /export/data
```

Let's setup the nfs export with the new drive/folder: `sudo nano /etc/exports`

Add the following line to `/etc/exports`, take node of the /24 network, you may want to adjust this to your specific local network. 

```bash
/export/data  10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
```

Apply the export

```bash
sudo exportfs -ra
sudo exportfs -v
```

### Simple Permissions

If you are in a single user environment and just want to allow all (home setup) to nfs you need to set the permission on the export folder.

Get your user id: `id -u`

Set ownership: `sudo chown 1000:1000 /export/data`

Set permissions:  `sudo chmod 777 /export/data`

Now we should be able to move files to/from this share without needing sudo.

Re-export the folder: `sudo exportfs -ra`

### Connect A Linux VM To NFS Share

On the end device you want to connect to the nfs share, install nfs: `sudo apt update -y && sudo apt install nfs-common -y`

Create the nfs folder locally and attach to the nfs export.

```bash
# Create a folder we will use to land our nfs mount
sudo mkdir /mnt/nfs

# Mount the newly created nfs share
sudo mount -t nfs -o vers=4.2,noatime,nodiratime 10.0.0.117:/export/data /mnt/nfs

# Validate the nfs share shows up
df -h /mnt/nfs

# Test by putting a unique file on the nfs share
touch /mnt/nfs/test_$(hostname)
```

### Connect A Windows VM To NFS Share

At this point Im going to stop and install NFS for windows 11 via the "Turn Windows Features On/Off" app.

From My Computer just map a network drive, `\\10.0.0.117` then click browse and you should see the export folder. Highlight and then click Ok.

At this point you should have full access to the share. 