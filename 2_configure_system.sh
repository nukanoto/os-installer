#!/bin/bash

WIRELESS="$1"
DISPLAY_SERVER="$2"

sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved
resolvectl status

sudo localectl set-keymap jp106

git clone https://aur.archlinux.org/paru
cd paru
makepkg -si
cd ..
rm -rf paru

sudo hostnamectl set-hostname archlinux

paru -Syyu

curl -fsSL https://raw.githubusercontent.com/nukanoto/dotfiles/master/bin/install.sh | bash
