---
title: "LFS Diaries - 4 follow-up || Chapter 3 Packages Install Issues"
date: 2025-02-09  
description: Chapter 3, Summary of Install issues I encountered
type: "post"  
tags: ["linux", "unix", "commands", "how-to", "technology", "lfs", "operating systems", "kernel"]
---

> Rest of the LFS posts can be viewed [**here**](https://techwebunraveled.xyz/tags/lfs/).

Below are the packages that I installed and the issues I faced:

## Glibc

### Error # 1 

```bash
## configure: error: you must configure in a separate build directory
## Solution: 
cd /mnt/LFS/sources/glibc-2.40
# Create separate build directory
mkdir glibc-build && cd "$_"
# Configure with the correct prefix
../configure --prefix=/mnt/LFS/usr/include && make && make install
```
### Error # 2

```bash
### Reading this error
    # wctomb.c:57:1: error: ‘artificial’ attribute ignored [-Werror=attributes]
    # 57 | libc_hidden_def (wctomb)
###
# Use the option --disable-werror
../configure --prefix=/mnt/LFS/usr \
             --disable-werror \
             --with-headers=$LFS/usr/include
```

## Automake

```bash
### Reading this error
    #   checking whether autoconf is installed... no
    #   configure: error: Autoconf 2.65 or better is required.
    #   Please make sure it is installed and in your PATH.
###
# Update the $PATH variable before configuring
export PATH=$PATH:/mnt/LFS/usr/bin
```
<br>

**Update**

<br>
After installing some packages I realised there are some env variables that are not set like **$LFS_TGT** because I didn't follow the rest of CH4 and went straight into compiling the packages ... I don't know how I missed the below part:

Create the required directory layout by issuing the following commands as root:

```bash
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
x86_64) mkdir -pv $LFS/lib64 ;;
esac
```

Programs in Chapter 6 will be compiled with a cross-compiler (more details can be found in section Toolchain Technical Notes). This cross-compiler will be installed in a special directory, to separate it from the other programs. Still acting as root, create that directory with this command:

```
mkdir -pv $LFS/tools
```

The book advises against using the root user, so far I didn't encounter issues but I'll follow it's recommendations anyways:

```bash
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
passwd lfs ## If you wish to give the user a password
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
x86_64) chown -v lfs $LFS/lib64 ;;
esac  
su - lfs # To log in as the new user  

## To setup the working environment

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF
## Configure parallel make
make -j32
cat >> ~/.bashrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF
```