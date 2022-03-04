#!/bin/bash

DISPLAY_SERVER="$1"

BASE_PKGS='noto-fonts-cjk noto-fonts-emoji ttf-nerd-fonts-symbols ttf-jetbrains-mono i3status-rust alsa-utils bluez curl fakeroot lm_sensors networkmanager speedtest-cli upower rofi alacritty fcitx5 fcitx5-im fcitx5-mozc-ut'

if [ "$DISPLAY_SERVER" == "wayland" ]; then
  BASE_PKGS+=" sway-git grim slurp"
elif [ "$DISPLAY_SERVER" == "x11" ]; then
  BASE_PKGS+=" i3-gaps xorg-server xorg-apps xorg-xinit xterm"

  cat << EOF > ~/.xprofile
export DefaultImModule=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
EOF

  echo 'exec i3' > ~/.xinitrc
fi


