#! /bin/bash

# Colors
 
red=`echo -en "\e[31m"`
green=`echo -en "\e[32m"`
bold=`echo -en "\e[1m"`
nocolor=`echo -en "\033[0m"`

# Uninstall Apps

readarray PACKAGES < remove.txt

echo
read -p "${red}${bold}Do you really want to remove these System Packages? [S/n]: ${nocolor}" response
echo

if [ "$response" == "S" -o "$response" == "s" ]; then
	sudo pacman -R ${PACKAGES[@]}
	
	echo
	echo "${green}${bold} SUCCESS! ${nocolor}"
	echo
	exit
fi	