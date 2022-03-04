#!/bin/bash

set -e

USER_NAME="$1"

sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen # コメントアウト解除
grep -E '^en_US\.UTF\-8 UTF\-8' /etc/locale.gen # 確認(コメントアウトされた行が一つでもあればOK)
locale-gen # 反映
echo "LANG=en_US.UTF-8" > /etc/locale.conf # LANG 環境変数を設定する

echo KEYMAP=jp106 > /etc/vconsole.conf

timedatectl set-timezone Asia/Tokyo

ntpdate -b ntp.nict.jp

systemctl enable ntpd.service

read -r -p "Press enter to edit /etc/ntp.conf:"
nvim /etc/ntp.conf

hwclock -w

read -r -p "Press enter to edit /etc/mkinitcpio.conf:"
nvim /etc/mkinitcpio.conf

mkinitcpio -p linux-zen

blkid

read -r -p 'Enter partition uuid' PARTUUID

mkdir -p /boot/loader/entries/

cat << EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img # amd製のCPUの場合
initrd  /initramfs-linux.img
options luks.uuid=$PARTUUID luks.options=allow-discards root=/dev/mapper/luks-$PARTUUID rootflags=subvol=@root rw
EOF

cat << EOF > /boot/loader/loader.conf
default arch
timeout 5
EOF

bootctl --path=/boot install

useradd -m -G wheel -s /bin/bash "$USER_NAME"
passwd "$USER_NAME"

EDITOR=nvim visudo
