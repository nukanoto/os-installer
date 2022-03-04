#!/bin/bash

INSTALL_DRIVE="$1"

wipefs --all "$INSTALL_DRIVE"
sgdisk -n 1::+512M -t 1:ef00 -c 1:"EFI System" "$INSTALL_DRIVE"
sgdisk -n 2:: -t 2:8300 -c 2:"Linux filesystem" "$INSTALL_DRIVE"

cryptsetup -v luksFormat "${INSTALL_DRIVE}2"
cryptsetup open "${INSTALL_DRIVE}2" cryptroot

mkfs.fat -F32 "${INSTALL_DRIVE}1" # FAT32でEFI Systemをフォーマット
mkfs.btrfs /dev/mapper/cryptroot # btrfsでLinux Systemをフォーマット

mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@root
umount /mnt
