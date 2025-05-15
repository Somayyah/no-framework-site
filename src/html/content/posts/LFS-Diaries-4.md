---
title: "LFS Diaries - 4 || Chapter 3"
date: 2025-02-09  
description: Chapter 3, Packages and Patches 
type: "post"  
tags: ["linux", "unix", "commands", "how-to", "technology", "lfs", "operating systems", "kernel"]
---

> Rest of the LFS posts can be viewed [**here**](https://techwebunraveled.xyz/tags/lfs/).

In this chapter, We'll download some packages to build a basic Linux system. The versions listed in the book are the ones that are known to work, and the instructions are based on using those specific versions. It's strongly recommended to stick to these versions because the building steps might not work with a different one, unless there’s a special note or update from LFS about it.

## Introduction

Once we've downloaded all the files and patches, we'll need a place to keep them where they’re easy to find and use throughout the entire process. We’ll also need a workspace to unpack the files and build the software. To keep things simple, I’m going to use `$LFS/sources` for both. This directory will hold all the downloaded files and serve as the workspace for building everything. By keeping everything on the LFS partition, we’ll have everything we need in one place, no matter what step we’re on. It’s just an easy way to stay organized!

Since there are dozens of packages listed, I’ll start by walking through one of them. If I run into any issues with the other packages, I’ll share those in separate posts later on.

## Preparing The System

We'll start first by creating the directory and giving it the appropriate permissions:

```
sudo mkdir -v $LFS/sources          # Create the directory to store source files and patches
sudo chmod -v a+wt $LFS/sources     # Make the directory writable for everyone and add the "sticky bit" to ensure only file owners can delete their own files within this directory
```

## Package Installation Methods

There are several ways to obtain the necessary packages / patches for LFS:
+ Downloaded individually as described in the next two sections.
+ For stable versions of the book, a tarball of all the needed files can be downloaded from one of the mirror sites:
listed at https://www.linuxfromscratch.org/mirrors.html#files.
• The files can be downloaded using wget and a wget-list:

```
wget --input-file=wget-list-systemd --continue --directory-prefix=$LFS/sources
```

## Installing Packages Manually

Let's install the **acl** package manually to understand the process:

```
Acl (2.3.2) - 363 KB:
Home page: https://savannah.nongnu.org/projects/acl
Download: https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz
MD5 sum: 590765dee95907dbc3c856f7255bd669
```

By obtaining the package archive and decompressing it after checking it's MD5 checksum:

```bash
# Step 1: Download the package using wget and save it to $LFS/sources/
wget https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz -O $LFS/sources/acl-2.3.2.tar.xz && \

# Step 2: Verify the MD5 checksum to ensure the file's integrity
echo "590765dee95907dbc3c856f7255bd669  $LFS/sources/acl-2.3.2.tar.xz" | md5sum -c && \

# Step 3: Extract the downloaded package into $LFS/sources/
tar -xf $LFS/sources/acl-2.3.2.tar.xz -C $LFS/sources/ && \

# Step 4: Remove the compressed file to save space
rm $LFS/sources/acl-2.3.2.tar.xz || echo "An error occurred during the process!"
```

We now have the package:

```bash
watari@LFS-Ubuntu:~$ ls /mnt/LFS/sources/acl-2.3.2/
ABOUT-NLS   configure     examples  libacl        m4           man     test
aclocal.m4  configure.ac  exports   libacl.pc.in  Makefile.am  po      tools
build-aux   doc           include   libmisc       Makefile.in  README
watari@LFS-Ubuntu:~$ 
```

## Building the Package

To build and configure the package we can follow the steps in $LFS/sources/acl-2.3.2/doc/INSTALL:

```bash
# Create the directory structure for $LFS/usr/local (not strictly necessary, as the Makefile will create these directories automatically during `make install`)
sudo mkdir -p $LFS/usr/{bin,include,lib}

# Configure, compile, and install the package into the LFS filesystem instead of the host system.
# The `--prefix=$LFS/usr` ensures that files are installed under $LFS/usr (e.g., binaries in $LFS/usr/bin, libraries in $LFS/usr/lib).
./configure && make && make install --prefix=$LFS/usr
```

The install isn't successful as we face this error:

```bash
watari@LFS-Ubuntu:/mnt/LFS/sources/acl-2.3.2$ ./configure && make && make install --prefix=$LFS/usr
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a race-free mkdir -p... /usr/bin/mkdir -p
..
checking where the gettext function comes from... libc
checking for attr/error_context.h... no

FATAL ERROR: attr/error_context.h does not exist.
Install the extended attributes (attr) development package.
Alternatively, run "make install-dev" from the attr source.
watari@LFS-Ubuntu:/mnt/LFS/sources/acl-2.3.2$ 
```

We are missing the **attr** package:

```bash
Attr (2.5.2) - 484 KB:
Home page: https://savannah.nongnu.org/projects/attr
Download: https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz
MD5 sum: 227043ec2f6ca03c0948df5517f9c927
```

which is listed second one in the book, so let's install it then try again with **acl**:

```bash
wget https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz -O $LFS/sources/attr-2.5.2.tar.gz && \
echo "227043ec2f6ca03c0948df5517f9c927  $LFS/sources/attr-2.5.2.tar.gz" | md5sum -c && \
tar -xf $LFS/sources/attr-2.5.2.tar.gz -C $LFS/sources/ && \
rm $LFS/sources/attr-2.5.2.tar.gz || echo "An error occurred during the process!"
```

Then:

```bash
cd $LFS/sources/attr-2.5.2
./configure --prefix=$LFS/usr && make && make install 
```

Now let's try again with the **acl** package:

```bash
root@LFS-Ubuntu:/mnt/LFS/sources/attr-2.5.2# cd ../acl-2.3.2/
root@LFS-Ubuntu:/mnt/LFS/sources/acl-2.3.2# ./configure --prefix=$LFS/usr && make && make install 
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
..
make[2]: Leaving directory '/mnt/LFS/sources/acl-2.3.2'
make[1]: Leaving directory '/mnt/LFS/sources/acl-2.3.2'
root@LFS-Ubuntu:/mnt/LFS/sources/acl-2.3.2# ^C
```

So far, we’ve successfully installed two packages. At this point, it’s a good idea to take a VM snapshot to save our progress. I’ll continue with the remaining packages, and in a follow-up post, I’ll share any issues or challenges I encounter along the way.

**Cheers!! 🐸**

**Update**

To determine the correct order for installing packages, refer to the **Appendix C: Dependencies** section.