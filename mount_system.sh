#!/bin/bash

INSTALL_DRIVE="$1"

mount -o subvol=@root /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "${INSTALL_DRIVE}1" /mnt/boot

genfstab -U /mnt >> /mnt/etc/fstab
