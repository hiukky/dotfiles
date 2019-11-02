#!/bin/bash

# Colors
 
green=`echo -en "\e[32m"`
blue=`echo -en "\e[34m"`
purple=`echo -en "\e[35m"`
bold=`echo -en "\e[1m"`
nocolor=`echo -en "\033[0m"`	

# Trizen
pacman -Q > installed.txt

readarray PACKAGES_INSTALLED < installed.txt

if [[ " ${PACKAGES_INSTALLED[*]} " != *" trizen "* ]]; then
	echo
	read -p "=> Install ${green}${bold} Trizen? [S/n]: ${nocolor}" response

	if [ "$response" == "S" -o "$response" == "s" ]; then
		sudo pacman -Syu		
		sudo pacman -S trizen
	fi
fi

# Install default Apps
echo
read -p "${blue}=> ${green}${bold}Do you want to install your default apps? [S/n]: ${nocolor}" response

readarray AUR < aur.txt
readarray MANJARO < manjaro.txt

installPackages () {
	# PACKAGES
	echo
	echo "${purple}${bold} => INSTALING PACKAGES ${nocolor}"
	echo

	trizen -S --noconfirm ${AUR[@]}
	sudo pacman -S --noconfirm ${MANJARO[@]}

	echo
	echo "${green}${bold} => UPDATING YOUR SYSTEM! ${nocolor}"
	echo
	sudo pacman -Syu
}

if [ "$response" == "S" -o $response == "s" ]; then 
	installPackages
	echo
	echo "${green}${bold} SUCCESS! ${nocolor}"
	echo
fi

rm -rf installed.txt