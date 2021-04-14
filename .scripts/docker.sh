#!/bin/bash

set -eE

printf "\n\nDOCKER"

printf "\n\nDownloading dependencies... \n\n"

sudo pacman -Syu docker docker-compose
sudo tee /etc/modules-load.d/loop.conf <<< "loop"
modprobe loop

sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo groupadd docker
sudo usermod -aG docker $USER

docker version

printf "\n\nDocker installed successfully! \n\n"
