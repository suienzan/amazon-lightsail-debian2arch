#!/bin/sh

# Copyright 2015, Timothy Redaelli <tredaelli@archlinux.info>: Original Author
# at <https://gitlab.com/drizzt/vps2arch>
# Copyright 2021, suienzan <suienzan@gmail.com>: Amazon Lightsail Debian2Arch

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

set -e

mirror="https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/"

iso="$mirror/iso/latest"
repo="$mirror/\$repo/os/\$arch"

ask_username_and_password() {
  echo "Enter Your Username: "
  read -r username
  echo "Enter Your Password: "
  read -r -s password
  echo "Retype Your Password: "
  read -r -s password2

  if [ "$password" = "$password2" ]; then
    echo "Your Username is $username"
    echo "Your Password is $password"
  else
    echo "Password doesn't match"
  fi
}

download_and_extract_bootstrap() {
  local _
  local filename
  wget -O- "$iso/sha1sums.txt" | grep -F "x86_64.tar.gz" >"sha1sums.txt"
  read -r _ filename <"sha1sums.txt"
  wget -O- "$iso/$filename" >"$filename"
  sha1sum -c sha1sums.txt || exit 1
  tar -xpzf "$filename"
}

install() {
  echo "Server = $repo" >/tmp/root.x86_64/etc/pacman.d/mirrorlist

  cat <<EOF | /tmp/root.x86_64/bin/arch-chroot /tmp/root.x86_64
pacman-key --init
pacman-key --populate archlinux
pacman -Syy
mount /dev/xvda1 /mnt
mount /dev/xvda15 /mnt/boot/efi
cd /mnt
rm -rf bin home lib32 libx32 media opt root sbin usr etc lib lib64 lost+found mnt srv var
mkdir -m 0755 -p /mnt/var/{cache/pacman/pkg,lib/pacman,log} /mnt/{dev,run,etc}
mkdir -m 1777 -p /mnt/tmp
mkdir -m 0555 -p /mnt/{sys,proc}
mount --bind /mnt /mnt
mount -t proc /proc "/mnt/proc"
mount --rbind /sys "/mnt/sys"
mount --rbind /run "/mnt/run"
mount --rbind /dev "/mnt/dev"
pacman -r /mnt --cachedir="/mnt/var/cache/pacman/pkg" -Sy --noconfirm base linux linux-firmware openssh xfsprogs sudo vi vim grub
cp -a /etc/pacman.d/gnupg "/mnt/etc/pacman.d/"       
cp -a /etc/pacman.d/mirrorlist "/mnt/etc/pacman.d/" 
genfstab -U /mnt >> /mnt/etc/fstab
sed -i "5,7d" /mnt/etc/fstab
test() {
  cat <<EOFA | chroot /mnt
mount /dev/xvda15 /boot/efi
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
cat << EOFB > /etc/systemd/network/20-wired.network
[Match]
Name=eth0

[Network]
DHCP=ipv4
EOFB
useradd -m -G wheel -s /bin/bash $username
echo -e "$password\n$password" | passwd $username
sed -i "s/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
systemctl enable systemd-networkd
systemctl enable sshd
grub-mkconfig -o /boot/grub/grub.cfg
EOFA
}
test
EOF
exit
}

cd /tmp
ask_username_and_password
download_and_extract_bootstrap
install
