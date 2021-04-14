#!/bin/bash

set -eE

printf "\n\nVIRTUALBOX"

printf "\n\nDownloading dependencies... \n\n"

sudo pacman -Syu virtualbox virtualbox-guest-iso linux-headers

sudo modprobe vboxdrv
sudo tee /etc/modules-load.d/virtualbox.conf <<< "vboxdrv"
sudo usermod -aG vboxusers $USER
sudo lsmod | grep vboxdrv

printf "\n\nVirtualbox installed successfully! \n\n"

virtualbox --help
