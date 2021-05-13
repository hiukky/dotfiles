#!/bin/bash

set -eE

printf "\n\nWebRTC \n\n"

printf "\n\nDownloading dependencies... \n\n"

sudo pacman -S pipewire pipewire-alsa pipewire-pulse xdg-desktop-portal xdg-desktop-portal-wlr libpipewire02 --noconfirm --needed

systemctl --user enable pipewire.socket pipewire-pulse.socket
systemctl --user enable pipewire.service pipewire-pulse.service

sudo sed -i 's/#metadata/metadata/g' /etc/pipewire/media-session.d/media-session.conf

printf "\n\nDone! \n\n"
