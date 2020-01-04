#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

# Enable AUR
sudo sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf

## SYSTEM
: '
 @method _installPkgs
 @return void
'
_installPkgs() {
  sudo pacman -Sy

  local PACKAGES=$(<${BASE_DIR}/scripts/packages/list-install.txt)

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
 @method _uninstallPkgs
 @return void
'
_uninstallPkgs() {
  local PACKAGES=$(<${BASE_DIR}/scripts/packages/list-uninstall.txt)

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

  # System
  comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq) > "${BASE_DIR}/scripts/packages/list-install.txt"
}


## NPM
_installNpmPkgs() {
  sudo pacman -Sy

  local PACKAGES=$(<${BASE_DIR}/scripts/packages/npm-install.txt)

  echo
  echo "${orange}${bold} INSTALLING NPM PACKAGES...${nocolor}"

  if [[ PACKAGES ]]; then
    local npm=$(pacman -Q npm)

    if [[ -z $npm ]]; then
      sudo pacman -S npm
    fi

    sudo npm install -g ${PACKAGES[@]}
  fi
}

: '
 @method _updateNpmPkgList
 @return void
'
_updateNpmPkgList() {
  # NPM | aplly "\├──|\/usr\/lib|\└──" lol
  local npm=$(npm list -g --depth 0)
  npm="$(echo ${npm//'/usr/lib'/''})"
  npm="$(echo ${npm//'├──'/''})"
  npm="$(echo ${npm//'└──'/''})"

  printf '%s\n' ${npm} > "${BASE_DIR}/scripts/packages/npm-install.txt"
}
