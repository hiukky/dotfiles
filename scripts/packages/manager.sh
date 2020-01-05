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

  local PACKAGES=$(<${BASE_DIR}/scripts/packages/system-install.txt)

  echo
  echo "${aqua}${bold} Installing Packages...${nocolor}"

  if [[ PACKAGES ]]; then
    local tz=$(pacman -Q trizen)

    if [[ -z $tz ]]; then
      sudo pacman -S trizen
    fi

    trizen -S --noconfirm --noinfo --noedit ${PACKAGES[@]}
	  sudo pacman -S --noconfirm ${PACKAGES[@]}
  fi

  echo
  echo "${green}${bold} Installed Packages! ${nocolor}"
}

: '
 @method _uninstallPkgs
 @return void
'
_uninstallPkgs() {
  local PACKAGES=$(<${BASE_DIR}/scripts/packages/list-uninstall.txt)

  echo
  echo "${aqua}${bold} Uninstalling Packages...${nocolor}"

  if [[ PACKAGES ]]; then
    sudo pamac remove ${PACKAGES[@]} --no-confirm
  fi

  echo
  echo "${green}${bold} Uninstalled Packages! ${nocolor}"
  echo
  sudo pacman -Sy
}

: '
 @method _updatePkgList
 @return void
'
_updatePkgList() {
  sudo pacman -Sy

  echo
  echo "${aqua}${bold} Updating Package List...${nocolor}"

  # System
  comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq) > "${BASE_DIR}/scripts/packages/system-install.txt"
  sleep 2
  echo
  echo "${green}${bold} Updated list! ${nocolor}"
  echo
}


## NPM
_installNpmPkgs() {
  sudo pacman -Sy

  local PACKAGES=$(<${BASE_DIR}/scripts/packages/npm-global.txt)

  echo
  echo "${aqua}${bold} Installing Packages...${nocolor}"

  if [[ PACKAGES ]]; then
    local npm=$(pacman -Q npm)

    if [[ -z $npm ]]; then
      sudo pacman -S npm
    fi

    sudo npm install -g ${PACKAGES[@]}
  fi

  echo
  echo "${green}${bold} Uninstalled Packages! ${nocolor}"
  echo
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

  printf '%s\n' ${npm} > "${BASE_DIR}/scripts/packages/npm-global.txt"
  sleep 2
  echo
  echo "${green}${bold} Updated list! ${nocolor}"
  echo
}

## VSCODE
: '
 @method _installCodeExtensions
 @return void
'
_installCodeExtensions() {
  local PACKAGES=$(<${BASE_DIR}/scripts/packages/vscode-extensions.txt)

  if [[ -n "${PACKAGES[@]}" ]]; then
    for ext in "${PACKAGES[@]}"; do
      $ext
    done
  fi

  sleep 3
  echo
  echo "${green}${bold} Installed Extensions! ${nocolor}"
  echo
}

: '
 @method _updateCodeExtensions
 @return void
'
_updateCodeExtensions() {
  code --list-extensions | xargs -L 1 echo code --install-extension > "${BASE_DIR}/scripts/packages/vscode-extensions.txt"
  sleep 2
  echo
  echo "${green}${bold} Updated list! ${nocolor}"
  echo
}
