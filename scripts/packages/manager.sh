#! /bin/bash
source "${BINPATH}/utils/colors.sh"

# Sync repositories
sudo pacman -Sy

# Enable AUR
sudo sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf

: '
 @method _install

 @return void
'
_install(){
  local PACKAGES=$(<${BINPATH}/packages/list-install.txt)

  echo
  echo "${aqua}${bold} INSTALLING PACKAGES...${nocolor}"

  if [[ PACKAGES ]]; then
    local tz=$(pacman -Q trizen)

    if [[ -z $tz ]]; then
      sudo pacman -S trizen
    fi

    trizen -S --noconfirm ${PACKAGES[@]}
	  sudo pacman -S --noconfirm ${PACKAGES[@]}
  fi

  exit
}

# Uninstall packages
_uninstall() {
  local PACKAGES=$(<${BINPATH}/packages/list-uninstall.txt)

  echo
  echo "${aqua}${bold} UNINSTALLING PACKAGES...${nocolor}"

  if [[ PACKAGES ]]; then
    sudo pamac remove ${PACKAGES[@]} --no-confirm
  fi

  exit
}

: '
 @method _updatePkgList

 @return void
'
_updatePkgList() {
  echo
  echo "${aqua}${bold} UPDATING PACKAGE LIST...${nocolor}"
  pacman -Qqet | sort > "${BINPATH}/packages/list-install.txt"
  echo
  exit
}
