#!/bin/bash

set -eE

printf "\n\nInstalling snap... \n\n"

DIR=$HOME/.tmp/snapd

[ ! -d "$DIR" ] && git clone https://aur.archlinux.org/snapd-git.git $DIR
cd $DIR
makepkg -si

sudo systemctl enable --now snapd.socket

rm -rf $DIR

snap --version

printf "\n\nDone! \n\n"
