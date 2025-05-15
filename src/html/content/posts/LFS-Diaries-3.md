---
title: "LFS Diaries - 3 || Chapter 2 Continued || Single Partition Approach"
date: 2025-02-09  
description: Chapter 2, prepering the system and it's partitions 
type: "post"  
tags: ["linux", "unix", "commands", "how-to", "technology", "lfs", "operating systems", "kernel"]
---

> Rest of the LFS posts can be viewed [**here**](https://techwebunraveled.xyz/tags/lfs/).

After preparing the new partition in the previous part we are now ready to create a new filesystem for it, as a reminder here is the new partition /dev/sda3:

```bash
watari@LFS-Ubuntu:~$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0     4K  1 loop /snap/bare/5
loop1    7:1    0  73.9M  1 loop /snap/core22/1722
loop2    7:2    0  73.9M  1 loop /snap/core22/1748
loop3    7:3    0 269.8M  1 loop /snap/firefox/4793
loop4    7:4    0 505.1M  1 loop /snap/gnome-42-2204/176
loop5    7:5    0  11.1M  1 loop /snap/firmware-updater/147
loop6    7:6    0  10.7M  1 loop /snap/firmware-updater/127
loop7    7:7    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop8    7:8    0  10.5M  1 loop /snap/snap-store/1173
loop9    7:9    0  38.8M  1 loop /snap/snapd/21759
loop10   7:10   0  44.4M  1 loop /snap/snapd/23545
loop11   7:11   0   500K  1 loop /snap/snapd-desktop-integration/178
loop12   7:12   0   568K  1 loop /snap/snapd-desktop-integration/253
sda      8:0    0  30.6G  0 disk 
├─sda1   8:1    0     1M  0 part 
├─sda2   8:2    0    10G  0 part /
└─sda3   8:3    0  20.6G  0 part 
sr0     11:0    1  56.9M  0 rom  /media/watari/VBox_GAs_7.1.4
```

## File System Types

LFS can work with any file system supported by the Linux kernel, but the most commonly used types are ext3 and ext4. Choosing the right file system depends on factors like file characteristics and partition size. Here's a breakdown:

+ **ext2**: Ideal for small partitions that don’t change often, such as /boot.
+ **ext3**: An improvement over ext2, featuring journaling to help recover from unclean shutdowns.
+ **ext4**: The latest in the ext family, offering enhancements like nano-second timestamps, support for very large files (up to 16 TB), and better performance.

Other file systems like FAT32, NTFS, JFS, and XFS serve specific needs. For more details, you can visit [this comparison](https://en.wikipedia.org/wiki/Comparison_of_file_systems), but for now, I’ll be sticking with ext4. To create an ext4 file system on the LFS partition, we use the command:<br><br>

```bash
watari@LFS-Ubuntu:~$ sudo mkfs -v -t ext4 /dev/sda3
[sudo] password for watari: 
Sorry, try again.
[sudo] password for watari: 
mke2fs 1.47.0 (5-Feb-2023)
fs_types for mke2fs.conf resolution: 'ext4'
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
1351680 inodes, 5399552 blocks
269977 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2153775104
165 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Filesystem UUID: 488d9fed-0cf8-4407-a051-e5ee7e60058f
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done  
```

<br> If you are using an existing swap partition, there is no need to format it. If a new swap partition was created, it will need to be initialized with this command:
<br>
```
mkswap /dev/NAME
```
Replace NAME  with the name of the swap partition.

## Setting Up the LFS Variable

To proceed, we need to ensure that the environment variable *LFS* is always defined and points to the directory where we will build the LFS system. I will use */mnt/LFS* as an example, following the book's instructions, but you can choose any directory name you prefer.<br><br>

If you're building LFS on a separate partition, this directory will act as the mount point for that partition. Pick a directory location and add the *LFS* variable to the end of your *~/.bashrc* file using the following commands:<br><br>

```
echo "export LFS=/mnt/LFS" >> ~/.bashrc
source ~/.bashrc
```

Having this variable set is useful because commands like *mkdir -v $LFS/tools* can be typed literally. The shell will automatically replace *$LFS* with */mnt/LFS* (or whatever value you set for the variable) when it processes the command.

## Preparing the File System Partitions

From the book here is the suggested layout:

+ Root Partition (/): 18 GB, less than the book but I think its ok
+ Swap Partition (/swap): 2 GB (adjust as needed)
+ GRUB BIOS Partition: 1 MB (only needed if using GPT with BIOS boot)
+ /boot Partition: 200 MB
+ /home Partition: Allocate remaining space after other partitions
+ /usr Partition: Optional, but if used, allocate 1-5 GB
+ /opt Partition: 5-10 GB for large packages
+ /tmp Partition: Optional, a few GB
+ /usr/src Partition: 30-50 GB for large source files

For now I'll use the single partition approach where all FileSystem directories fall under / in a single partition, its a much simpler approach and I'll attempt the multi-partition approach in the future, we start with the below command:

```
mkdir -pv $LFS
sudo mount -v -t ext4 /dev/sda3 $LFS
```

Now the layout of the host should look like this:
<br><br>

```bash
watari@LFS-Ubuntu:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           392M  1.5M  391M   1% /run
/dev/sda2       9.7G  6.3G  2.9G  69% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           392M  140K  392M   1% /run/user/1000
/dev/sr0         57M   57M     0 100% /media/watari/VBox_GAs_7.1.4
/dev/sda3        21G   24K   20G   1% /mnt/LFS
watari@LFS-Ubuntu:~$ 
```

## Finishing the LFS Filesystem

Now we have to create the rest of the directories:

```
sudo mkdir -p $LFS/{boot,home,root,swap,usr/src,opt,tmp}
```

## Saving Progress After Reloading the VM

To ensure that we don't lose our work we'll update /etc/fstab as below:

```
echo "/dev/sda3  $LFS  ext4  defaults  0  2" | sudo tee -a /etc/fstab > /dev/null
```

In this chapter, we prepared the LFS partition, created the necessary directory structure, and configured the system for building LFS. With the foundation now in place, we’re ready to move on to compiling and installing the required packages in the next chapter