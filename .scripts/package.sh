#!/bin/bash

set -eE

cd ../.packages

printf "\n\nPACKAGES"

printf "\n\nInstalling Archlinux packages ... \n\n"
sudo pacman -S $(cat "arch") --noconfirm --needed

printf "\n\nInstalling AUR packages ... \n\n"
yay -S $(cat "aur") --noconfirm

printf "\n\nInstalling Snap packages ... \n\n"
sudo snap install $(cat "snap")

printf "\n\nInstalling NPM packages ... \n\n"
sudo npm install -g $(cat "npm")

printf "\n\nDone! \n\n"
