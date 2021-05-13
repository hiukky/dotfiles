#!/bin/bash

DAEMON=$(cat << EOF
{
    "dns": ["10.0.0.2", "8.8.8.8"]
}
EOF
)

set -eE

printf "\n\nDOCKER"

printf "\n\nDownloading dependencies... \n\n"

sudo pacman -Syu docker docker-compose
sudo tee /etc/modules-load.d/loop.conf <<< "loop"
modprobe loop

sudo tee /etc/docker/daemon.json <<< $DAEMON

sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo groupadd docker &>/dev/null
sudo usermod -aG docker $USER

sudo chmod 666 /var/run/docker.sock

docker version

printf "\n\nDocker installed successfully! \n\n"
