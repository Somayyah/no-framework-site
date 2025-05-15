---
title: "Set NVChad on WSL2"
date: 2024-12-27
description: "How to set up NVChad, neovim, and nerdfont on WSL2"
type: "post"
tags: ["how-to", "linux", "unix", "commands", "technology", "hacks", "operating systems",  "explain-like-i'm-five"]
---

In this post, I will explain the process to configure [nvim](https://neovim.io/) with [NVChad](https://nvchad.com/) and customize it with [nerdfont](https://github.com/ryanoasis/nerd-fonts).

For reference I use Ubuntu 24.04 LTS on Windows 11, but I assume it would work with other setups.

```bash
watari@DESKTOP:~$ pfetch
         _    watari@DESKTOP
     ---(_)   os     Ubuntu 24.04 LTS on Windows 10 [WSL2]
 _/  ---  \   host   x86_64
(_) |   |     kernel 5.15.167.4-microsoft-standard-WSL2
  \  --- _/   uptime 1d 18h 28m
     ---(_)   pkgs   536
              memory 967M / 3846M

watari@DESKTOP:~$
```

# Pre-requisites

+ Neovim 0.10, delete old neovim and its folders
+ Nerd Font as your terminal font.
    Make sure the nerd font you set doesn't end with Mono to prevent small icons.
    Example : JetbrainsMono Nerd Font and not JetbrainsMono Nerd Font Mono
    Ripgrep is required for grep searching with Telescope (OPTIONAL).
+ GCC / Make

# Install neovim 0.10

You may already have another version installed, it's best to delete it first otherwise we'll have issues, to check nvim version:

```bash
watari@DESKTOP:~$ nvim --version
NVIM v0.10.2
Build type: Release
LuaJIT 2.1.1713484068
Run "nvim -V1 -v" for more info
```

To delete it on Ubuntu I used below:

```bash
sudo apt-get remove --auto-remove neovim
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```
This should remove nvim and it's configuration, then on the terminal install neovim as below:

```bash
wget https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
sudo mv nvim-linux64/bin/nvim /bin
sudo mv nvim-linux64/lib/* /usr/local/lib/
sudo mv nvim-linux64/share/* /usr/local/share/
sudo ldconfig
```

Now nvim is working without issues, next we will setup nerdfonts.

## Nerdfont setup

To setup nerdfonts for WSL on windows navigate to:

https://www.nerdfonts.com/font-downloads

I downloaded [BigBlue Terminal](https://www.programmingfonts.org/#bigblue-terminal), next extract the fonts into the directory C:\Windows\Fonts, since I'm using windows terminal If you use Windows Terminal.I followed these steps:

Go to settings -> select the ubuntu distro or whatever distro you use -> scroll down to additional settings and select appearance -> For font face select the nerdfont you've installed then click save.

## Install GCC and MAKE

Usually they are already installed, you can check their version as below:

```bash
watari@DESKTOP:~$ gcc -v
..
gcc version 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
watari@DESKTOP:~$ make -v
GNU Make 4.3
..
watari@DESKTOP:~$
```

Anyways to install GCC and MAKE on Ubuntu:

```bash
sudo apt update
sudo apt install build-essential
```

## Install NVChad

First install node:

```bash
sudo apt install npm
```
Then we install nvchad and run nvim:

```bash
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
```

You will be presented with below screen:

![Image of the terminal showing NVChad is now installed, and presenting the options available](/images/image.png)

Now we have NVChad installed and ready to be used, you can farther customize it to support different languages and features.