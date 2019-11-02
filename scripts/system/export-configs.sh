#! /bin/bash

# Colors

green=`echo -en "\e[32m"`
bold=`echo -en "\e[1m"`
nocolor=`echo -en "\033[0m"`

# Termin for Nemo
echo
echo "${green}${bold}Set Terminal for Nemo..."
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'xfce4-terminal' 
echo