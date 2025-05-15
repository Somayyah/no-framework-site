---
title: "LFS Diaries - 2 || Chapter 2 Continued"
date: 2025-02-06  
description: Chapter 2, prepering the system and it's partitions 
type: "post"  
tags: ["linux", "unix", "commands", "how-to", "technology", "lfs", "operating systems", "kernel"]
---

> Rest of the LFS posts can be viewed [**here**](https://techwebunraveled.xyz/tags/lfs/).

**After setting up a new Ubuntu VM with 30 GB of storage (double the previous 15 GB), I retraced the steps from the first post. Now, I'm ready to move forward while taking snapshots at key milestones.** From the guide we read below:
<br><br>
> Like most other operating systems, LFS is usually installed on a dedicated partition. The recommended approach to building an LFS system is to use an available empty partition or, if you have enough unpartitioned space, to create one.
> 
> A minimal system requires a partition of around 10 gigabytes (GB). This is enough to store all the source tarballs and compile the packages. However, if the LFS system is intended to be the primary Linux system, additional software will probably be installed which will require additional space. A 30 GB partition is a reasonable size to provide for growth. The LFS system itself will not take up this much room. A large portion of this requirement is to provide sufficient free temporary storage as well as for adding additional capabilities after LFS is complete. Additionally, compiling packages can require a lot of disk space which will be reclaimed after the package is installed.
> 
> Because there is not always enough Random Access Memory (RAM) available for compilation processes, it is a good idea to use a small disk partition as swap space. This is used by the kernel to store seldom-used data and leave more memory available for active processes. The swap partition for an LFS system can be the same as the one used by the host system, in which case it is not necessary to create another one.
> 
> Start a disk partitioning program such as cfdisk or fdisk with a command line option naming the hard disk on which the new partition will be created—for example /dev/sda for the primary disk drive. Create a Linux native partition and a swap partition, if needed. Please refer to cfdisk(8) or fdisk(8) if you do not yet know how to use the programs.
<br><br>

As a summary:

+ 30 gigs should be a reasonable amount to accomodate for system growth.
+ It's a good idea to create a /swap partition to be used in case there isn't enough RAM.
+ We can use ```fdisk``` or ```cfdisk``` to create these partitions.

## Expected Partitions

When setting up your disk layout, consider the following partitions:  

### Root Partition (/)

The root LFS partition (distinct from the `/root` directory) should ideally be 20 GB. This size strikes a balance between providing enough space to build LFS and most BLFS packages, while still allowing room for additional partitions for experimentation.  

### Swap Partition (/swap)

Most distributions automatically create a swap partition. The traditional recommendation is to allocate twice the physical RAM for swap, but this is rarely necessary. If disk space is limited, a 2 GB swap partition should suffice. Be sure to monitor disk swapping to determine if adjustments are needed.  

### GRUB BIOS Partition

If your boot disk uses a GUID Partition Table (GPT), you’ll need to create a small partition (typically 1 MB) for GRUB. This partition doesn’t need to be formatted but must exist to install the bootloader. When using `fdisk`, this partition is labeled as "BIOS Boot," or it will have a code of `EF02` if using the `gdisk` command.  

> **Note**  
> The GRUB BIOS partition must reside on the boot disk used by the BIOS, which may differ from the disk holding the LFS root partition. Keep in mind that the need for a GRUB BIOS partition depends solely on the partition table type of the boot disk.  

### Convenience Partitions

While not mandatory, the following partitions can simplify management and improve system functionality:  

- **`/boot`**
  Highly recommended for storing kernels and boot information. To avoid boot issues with larger disks, place this as the first physical partition on your primary disk. A size of 200 MB is typically sufficient.  

- **`/boot/efi`**
  Required for UEFI systems. Refer to the BLFS documentation for setup details.  

- **`/home`**  
  Strongly recommended for keeping user data and customization separate from the operating system. This is especially useful for sharing data across distributions or LFS builds. Allocate as much space as your disk allows.  

- **`/usr`**
  Since LFS links `/bin`, `/lib`, and `/sbin` to `/usr`, it contains all critical system binaries. While a separate `/usr` partition is not essential for LFS, creating one could allow for a minimal root partition (e.g., 1 GB), ideal for thin clients or diskless workstations (where `/usr` is mounted remotely). Note that an **initramfs** (not covered in LFS) is required for this setup.  

- **`/opt`**
  Useful in BLFS for installing large packages (e.g., KDE, Texlive) without cluttering the `/usr` hierarchy. A partition size of 5–10 GB is usually sufficient.  

- **`/tmp`** 
  A separate `/tmp` partition is rare but helpful for thin clients. Typically, a few GB is enough. Alternatively, if you have sufficient RAM, consider mounting `/tmp` as a **tmpfs** for faster temporary file access.  

- **`/usr/src`**
  Provides a shared location for BLFS source files and can also be used to build BLFS packages. Allocate 30–50 GB to ensure ample space for large source files and builds.  

Alright so let's create these partition, but first, let's have a review for..

## Fdisk Command

fdisk is a command used to create partitions which are sectors or segments within a storage space, it allows you to mound a file system, without partitioning the storage would be like an unusable chunk of memory. To view a list of disks and the partitions we can use the below command:

```bash
watari@LFS-Ubuntu:~$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0    7:0    0     4K  1 loop /snap/bare/5
loop1    7:1    0  74.3M  1 loop /snap/core22/1564
loop2    7:2    0 269.8M  1 loop /snap/firefox/4793
loop3    7:3    0 505.1M  1 loop /snap/gnome-42-2204/176
loop4    7:4    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop5    7:5    0  10.5M  1 loop /snap/snap-store/1173
loop6    7:6    0  38.8M  1 loop /snap/snapd/21759
loop7    7:7    0  10.7M  1 loop /snap/firmware-updater/127
loop8    7:8    0   500K  1 loop /snap/snapd-desktop-integration/178
sda      8:0    0  30.6G  0 disk 
├─sda1   8:1    0     1M  0 part 
└─sda2   8:2    0  30.6G  0 part /
sr0     11:0    1  56.9M  0 rom  /media/watari/VBox_GAs_7.1.4
watari@LFS-Ubuntu:~$ 
```

We can see that I have a sigle SATA disk sda which has two partitions sda1 and sda2, sda1 has 1M while sda2 has 30 Gigs, if we use the below command:

```bash
watari@LFS-Ubuntu:~$ sudo fdisk -l /dev/sda
[sudo] password for watari: 
Disk /dev/sda: 30.6 GiB, 32856499712 bytes, 64172851 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: D0D2057A-EC39-4E81-9B65-9E0798E23C28

Device     Start      End  Sectors  Size Type
/dev/sda1   2048     4095     2048    1M BIOS boot
/dev/sda2   4096 64169983 64165888 30.6G Linux filesystem
watari@LFS-Ubuntu:~$ 
```

We can view some useful information about our sda disk and it's partitions, for example /dev/sda1 starts from the sector 2048 and ends at 4095. We can view and edit partitions in the sda disk using the below command:

```bash
watari@LFS-Ubuntu:~$ sudo fdisk /dev/sda

Welcome to fdisk (util-linux 2.39.3).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

This disk is currently in use - repartitioning is probably a bad idea.
It's recommended to umount all file systems, and swapoff all swap
partitions on this disk.


Command (m for help): 
```

We see a warning message to proceed with caution, I'll proceed anyways as we are testing within a VM so hopefully we can just revert the snapshot if anything happens. Let's enter m and see the available options:

```bash
Command (m for help): m

Help:

  GPT
   M   enter protective/hybrid MBR

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty MBR (DOS) partition table
   s   create a new empty Sun partition table

```

It seems that we don't have much partitioned space in disk a:

```bash
Command (m for help): F

Unpartitioned space /dev/sda: 1.38 MiB, 1451008 bytes, 2834 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

   Start      End Sectors  Size
64169984 64172817    2834  1.4M

Command (m for help): 
```

After printing the partition table we get this layout:

```bash
Command (m for help): p
Disk /dev/sda: 30.6 GiB, 32856499712 bytes, 64172851 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: D0D2057A-EC39-4E81-9B65-9E0798E23C28

Device     Start      End  Sectors  Size Type
/dev/sda1   2048     4095     2048    1M BIOS boot
/dev/sda2   4096 64169983 64165888 30.6G Linux filesystem

Command (m for help): 
```

We can also print some information about each partition:

```bash
Command (m for help): i
Partition number (1,2, default 2): 1

         Device: /dev/sda1
          Start: 2048
            End: 4095
        Sectors: 2048
           Size: 1M
           Type: BIOS boot
      Type-UUID: 21686148-6449-6E6F-744E-656564454649
           UUID: 703BC056-CF73-4AA4-A223-FB9EAF0F7E37

Command (m for help): i
Partition number (1,2, default 2): 2

         Device: /dev/sda2
          Start: 4096
            End: 64169983
        Sectors: 64165888
           Size: 30.6G
           Type: Linux filesystem
      Type-UUID: 0FC63DAF-8483-4772-8E79-3D69D8477DE4
           UUID: BE54BC38-C9A3-4087-A9CF-FAE88E66C6F3

Command (m for help): 
```

### Creating our new partition

While partitioning, we should be aware of certain factors. 
+ On a disk, we can have a maximum of four partitions.
+ The partitions are of two types.
    + Primary
    + Extended
+ Extended partitions can have logical partitions inside it.
+ Among the four possible partitions, the possible combinations are.
    + All 4 primary partitions
    + 3 primary partitions and 1 extended partition

From the above outputs we see that we don't have enough unpartitioned space, we do however have almost 26 Gigs of empty space in SDA2, so if we deallocate it somehow then we can use it for the LFS root "/" partition, I'm not worried of any corruption as this is a VM and we can always revert back the snapshot. 

Since the root of the host system is already mounted on the same partition we are trying to shrink, then we have to use a liveCD first because we have to unmount the file system first, and we can't do that since it's already in use.

First let's mount back the ubuntu ISO image on our machine by powering off the machine first, then navigate to settings > storage and click on the + icon in **Controller: IDE**, then add the ubuntu ISO image if it's not already there.

Next after restarting the machine, while it's booting click on F12, you can use the soft keyboard on VBox if its easier to enter the keys. After booting from the LiveCD we can start with shriking our system.

After starting the system again we use lsblk to view the disks:

```bash
ubuntu@ubuntu:~$ lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0     7:0    0   1.6G  1 loop /rofs
loop1     7:1    0   471M  1 loop
loop2     7:2    0 874.4M  1 loop
loop3     7:3    0     4K  1 loop /snap/bare/5
loop4     7:4    0  74.3M  1 loop /snap/core22/1564
loop5     7:5    0 269.8M  1 loop /snap/firefox/4793
loop6     7:6    0  10.7M  1 loop /snap/firmware-updater/127
loop7     7:7    0 505.1M  1 loop /snap/gnome-42-2204/176
loop8     7:8    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop9     7:9    0  10.5M  1 loop /snap/snap-store/1173
loop10    7:10   0  38.8M  1 loop /snap/snapd/21759
loop11    7:11   0   500K  1 loop /snap/snapd-desktop-integration/178
loop12    7:12   0 149.6M  1 loop /snap/thunderbird/507
loop13    7:13   0 116.8M  1 loop /snap/ubuntu-desktop-bootstrap/237
sda       8:0    0  30.6G  0 disk
├─sda1    8:1    0     1M  0 part
└─sda2    8:2    0  30.6G  0 part
sr0      11:0    1   5.8G  0 rom  /cdrom
sr1      11:1    1  56.9M  0 rom
ubuntu@ubuntu:~$ █
```

sda2 is out target, it should already be unmounted since we're on live CD but just to be sure:

```sudo umount /dev/sda2```

next let's do a filecheck on this partition:

```sudo e2fsck -f /dev/sda2```

Next we gonna try to resize the **filesystem** to 10 Gigs as below:

```sudo resize2fs /dev/sda2 10G```

The filesystem is now resized, but now we need to shrink the partition itself using fdisk and with the options below in order:

```sudo fdisk /dev/sda```

+ p : to print the partitions, find the start sector number of sda2
+ d : to delete /dev/sda2 and choose the partition, don't worry this won't delete data!
+ n : to create the new smaller partition, the start sector  is the same as before, but for the end sector I selected +10G which automatically allocates 10 Gigs

After saving the progress with **w**, we now resize the system again with:

```sudo resize2fs /dev/sda2```

> Note: If you got the error **bad magic number in superblock** you can easily resolve it with running ```sudo e2fsck -f /dev/sda2``` 

Then we create a new partition from the unallocated space using fdisk again and type n to create the new partition, since I want to use the remaining empty space I just pressed enter on all the options then saved the progress with w. Now lsblk command shows the new partition successfully created:

```bash
ubuntu@ubuntu:~$ lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0     7:0    0   1.6G  1 loop /rofs
loop1     7:1    0   471M  1 loop
loop2     7:2    0 874.4M  1 loop
loop3     7:3    0     4K  1 loop /snap/bare/5
loop4     7:4    0  74.3M  1 loop /snap/core22/1564
loop5     7:5    0 269.8M  1 loop /snap/firefox/4793
loop6     7:6    0  10.7M  1 loop /snap/firmware-updater/127
loop7     7:7    0 505.1M  1 loop /snap/gnome-42-2204/176
loop8     7:8    0  91.7M  1 loop /snap/gtk-common-themes/1535
loop9     7:9    0  10.5M  1 loop /snap/snap-store/1173
loop10    7:10   0  38.8M  1 loop /snap/snapd/21759
loop11    7:11   0   500K  1 loop /snap/snapd-desktop-integration/178
loop12    7:12   0 149.6M  1 loop /snap/thunderbird/507
loop13    7:13   0 116.8M  1 loop /snap/ubuntu-desktop-bootstrap/237
sda       8:0    0  30.6G  0 disk
├─sda1    8:1    0     1M  0 part
├─sda2    8:2    0    10G  0 part
└─sda3    8:3    0  20.6G  0 part
sr0      11:0    1   5.8G  0 rom  /cdrom
sr1      11:1    1  56.9M  0 rom
ubuntu@ubuntu:~$ █
```

After restarting the machine and booting from the hard disk we find that the changes have persisted and the root file system is mounted successfully so now we can go through with the next steps.