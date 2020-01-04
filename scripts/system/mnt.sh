#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

: '
  @method _mountPartition
  @return void
'
_mount () {
	# List Partitions
	echo
	echo "${aqua}${bold}List Partitions... ${nocolor}"
	echo

	lsblk

	echo
	echo "${orange}${bold}Obs.: Your partition you want to mount may only have ID as the primary name!"
	echo
	echo "  ex: ${green}d9e2bf27-6a80-48cb-876a-1bd0a${nocolor}"

	# Number of Partition
	echo
	read -p "${bold} => Which partition do you want to mount? ${nocolor}[sda${green}${bold}?${nocolor}] ${green}${bold}Number${nocolor}: " partition

	while [ -z "$partition" ]; do
		read -p "${bold} => Which partition do you want to mount? ${nocolor}[sda${green}${bold}?${nocolor}] -> ${green}${bold}Number${nocolor}: " partition
	done

	# Name of Directory
	echo
	read -p "${bold} => What name do you want for your partition? ${nocolor}[ex: ${green}${bold}Backup${nocolor}]: " name

	while [ -z "$name" ]; do
		read -p "${bold} => What name do you want for your partition? ${nocolor}[ex: ${green}${bold}Backup${nocolor}]: " name
	done

	echo

	# Confirm
	echo "${orange}${bold}Confirm your changes: ${nocolor}"
	echo
	echo "--| Partition: ${green}${bold} /dev/sda${partition}/ ${nocolor}"
	echo "--|      Name: ${green}${bold} ${name} ${nocolor}"
	echo
	read -p "${orange}${bold} All right? .. let's continue? [S/N]: ${nocolor}" response

	if [ "$response" == "S" -o "$response" == "s" ]; then
		if [ -n $partition ] && [ -n $name ]; then
			# 01
			sudo chown root:disk /dev/sda"${partition}"

			# 02
			echo
			echo "${purple}${bold}--| Creating partition...${nocolor}"
			sudo mkdir /run/media/$(whoami)/"${name}"
			echo
			sleep .2

			# 03
			echo "${purple}${bold}--| Mounting partition...${nocolor}"
			sudo mount /dev/sda"${partition}" /run/media/$(whoami)/"${name}"
			sudo e2label /dev/sda"${partition}" $name
			echo
			sleep .2

			# 04
			echo "${purple}${bold}--| Granting Access Permissions...${nocolor}"
			sudo chown $USER:$USER /run/media/$(whoami)/"${name}"
			echo
			sleep .2

			# Finish
			echo "${green}${bold} Completed! ${nocolor}"
			echo
		else
			exit
		fi
	fi
}

: '
  @method _mountPartition
  @return void
'
_mountPartition() {
  echo
  echo "${red}${bold} => The following procedure can risk your Data if it is done incorrectly!! ${nocolor}"
  read -p "${orange}${bold}... Do you wish to continue? [S/N]: ${nocolor}" response


  if [ "$response" == "S" -o "$response" == "s" ]; then
    _mount || exit
  fi
}
