# Amazon Lightsail Debian2Arch

A script used to convert a Amazon Lightsail, running Debian 10, to _Arch Linux_.
The original script [vps2arch](https://gitlab.com/drizzt/vps2arch/) works but will breaks down after restore form snapshots.

## Disclaimer

> I'm not responsible for any damage in your system and/or any violation of the agreement between you and your vps provider.  
> **Use at your own risk!**

## How To

Download the script on your _VPS_ and execute it with root privileges

**WARNING** The script will **delete** any data in your _VPS_!

    wget https://raw.githubusercontent.com/suienzan/amazon-lightsail-debian2arch/main/debian2arch.sh
    bash ./debian2arch.sh

## Optional

This script use `https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/` as Mirror. Edit it as needed.
