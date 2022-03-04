#!/bin/bash

set -e

CPU="$1"
GPU="$2"
WIRELESS="$3"

if [ "$WIRELESS" == "True" ]; then
  WIRELESS=1
elif [ "$WIRELESS" == "False" ]; then
  WIRELESS=0
fi

BASE_PKGS='base-devel linux-zen linux-firmware dosfstools efibootmgr btrfs-progs neovim dhcpcd ntp sed'

if [ "$CPU" == "amd" ]; then
  BASE_PKGS+=" amd-ucode"
elif [ "$CPU" == "intel" ]; then
  BASE_PKGS+=" intel-ucode"
fi

if [ "$GPU" == "nvidia" ]; then
  BASE_PKGS+=" nvidia"
fi

# TODO: install iwd if wireless is false
if [ $WIRELESS ]; then
  BASE_PKGS+=" iwd"
fi

cat << EOF > /etc/pacman.d/mirrorlist
Server = https://ftp.jaist.ac.jp/pub/Linux/ArchLinux/\$repo/os/\$arch
Server = https://jpn.mirror.pkgbuild.com/\$repo/os/\$arch
Server = https://mirrors.cat.net/archlinux/\$repo/os/\$arch
Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/\$repo/os/\$arch
Server = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/\$repo/os/\$arch
Server = http://mirrors.cat.net/archlinux/\$repo/os/\$arch
EOF

pacman -Syy

pacstrap /mnt $BASE_PKGS
