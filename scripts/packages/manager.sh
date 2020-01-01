#! /bin/bash
source "${BINPATH}/utils/colors.sh"

# Enable AUR
sudo sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf

: '
 @method _install

 @return void
'
_install(){
  sudo pacman -Sy

  local PACKAGES=$(<${BINPATH}/packages/list-install.txt)

  echo
  echo "${aqua}${bold} INSTALLING PACKAGES...${nocolor}"

  if [[ PACKAGES ]]; then
    local tz=$(pacman -Q trizen)

    if [[ -z $tz ]]; then
      sudo pacman -S trizen
    fi

    trizen -S --noconfirm --noinfo --noedit ${PACKAGES[@]}
	  sudo pacman -S --noconfirm ${PACKAGES[@]}
  fi
}

: '
 @method _uninstall

 @return void
'
_uninstall() {
  local PACKAGES=$(<${BINPATH}/packages/list-uninstall.txt)

  echo
  echo "${aqua}${bold} UNINSTALLING PACKAGES...${nocolor}"

  if [[ PACKAGES ]]; then
    sudo pamac remove ${PACKAGES[@]} --no-confirm
  fi

  sudo pacman -Sy
}

: '
 @method _updatePkgList

 @return void
'
_updatePkgList() {
  sudo pacman -Sy

  echo
  echo "${aqua}${bold} UPDATING PACKAGE LIST...${nocolor}"
  comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq) > "${BINPATH}/packages/list-install.txt"
  echo
}
