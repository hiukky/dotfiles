#!/bin/bash

set -eE

printf "\n\nQEMU"

printf "\n\nDownloading dependencies... \n\n"
sudo pacman -Syu archiso virt-manager qemu vde2 ebtables dnsmasq bridge-utils openbsd-netcat

sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service

sudo sed -i 's/#unix_sock_group/unix_sock_group/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms/unix_sock_rw_perms/g' /etc/libvirt/libvirtd.conf

sudo usermod -a -G libvirt $(whoami)

sudo newgrp libvirt << EONG
    systemctl restart libvirtd.service
    modprobe -r kvm_intel
    modprobe kvm_intel nested=1
    virsh net-define --file /usr/share/libvirt/networks/default.xml
    virsh net-start default
    virsh net-autostart --network default
    echo "options kvm-intel nested=1" | tee /etc/modprobe.d/kvm-intel.conf
EONG

printf "\n\nDone! \n\n"
