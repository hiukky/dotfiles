#!/bin/bash

set -eE

declare -a ARCH=(
    nodejs
    npm
    yarn
    thunar
    tumbler
    ttf-cascadia-code
    repo
    neofetch
    vagrant
    net-tools
    transmission-gtk
    discord
    vlc
    mousepad
    grim
    slurp
)

declare -a AUR=(
    visual-studio-code-bin
    figma-linux
    insomnia
    stacer
    beekeeper-studio-bin
    slack-desktop
    telegram-desktop-bin
    grimshot
    wl-clipboard
)

declare -a NPM=(
    vercel
    npm-check-updates
    yalc
)

printf "\n\nPACKAGES"

printf "\n\nInstalling Archlinux packages ... \n\n"
sudo pacman -S ${ARCH[@]} --noconfirm --needed

printf "\n\nInstalling AUR packages ... \n\n"
yay -S ${AUR[@]} --noconfirm

printf "\n\nInstalling NPM packages ... \n\n"
sudo npm install -g ${NPM[@]}

printf "\n\nDone! \n\n"
