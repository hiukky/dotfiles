#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

# Enable AUR
sudo sed -i 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf

## SYSTEM
: '
 @method _installPkgs
 @return void
 @params {string} de
'
_installPkgs() {
  sudo pacman -Sy

  local de=$1
  local PACKAGES=$(<${BASE_DIR}/environment/${de}/packages/system-install.txt)

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
  echo "${green}${bold} System packages installed! ${nocolor}"
}

: '
 @method _uninstallPkgs
 @return void
 @params {string} de
'
_uninstallPkgs() {
  local de=$1
  local PACKAGES=$(<${BASE_DIR}/environment/${de}/packages/list-uninstall.txt)

  echo
  echo "${aqua}${bold} Uninstalling Packages...${nocolor}"

  if [[ PACKAGES ]]; then
    sudo pamac remove ${PACKAGES[@]} --no-confirm
  fi

  echo
  echo "${green}${bold} System uninstalled packages! ${nocolor}"
  echo
  sudo pacman -Sy
}

: '
 @method _updatePkgList
 @return void
 @params {string} de
'
_updatePkgList() {
  sudo pacman -Sy

  local de=$1

  echo
  echo "${aqua}${bold} Updating Package List...${nocolor}"

  _creatDirIfNoExists $de

  comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq) > "${BASE_DIR}/environment/${de}/packages/system-install.txt"
  sleep 2
  echo
  echo "${green}${bold} System updated package list! ${nocolor}"
  echo
}


## NPM
: '
 @method _installNpmPkgs
 @return void
 @params {string} de
'
_installNpmPkgs() {
  local de=$1

  sudo pacman -Sy

  local PACKAGES=$(<${BASE_DIR}/environment/${de}/packages/npm-global.txt)

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
  echo "${green}${bold} NPM packages installed! ${nocolor}"
  echo
}

: '
 @method _updateNpmPkgList
 @return void
 @params {string} de
'
_updateNpmPkgList() {
  local de=$1

  # NPM | aplly "\├──|\/usr\/lib|\└──" lol
  local npm=$(npm list -g --depth 0)
  npm="$(echo ${npm//'/usr/lib'/''})"
  npm="$(echo ${npm//'├──'/''})"
  npm="$(echo ${npm//'└──'/''})"

  _creatDirIfNoExists $de

  printf '%s\n' ${npm} > "${BASE_DIR}/environment/${de}/packages/npm-global.txt"
  sleep 2
  echo
  echo "${green}${bold} NPM updated package list! ${nocolor}"
  echo
}

## VSCODE
: '
 @method _installCodeExtensions
 @return void
 @params {string} de
'
_installCodeExtensions() {
  local de=$1
  local PACKAGES=$(<${BASE_DIR}/environment/${de}/packages/vscode-extensions.txt)

  if [[ -n "${PACKAGES[@]}" ]]; then
    for ext in "${PACKAGES[@]}"; do
      $ext
    done
  fi

  sleep 3
  echo
  echo "${green}${bold} VS Code extensions installed! ${nocolor}"
  echo
}

: '
 @method _updateCodeExtensions
 @return void
 @params {string} de
'
_updateCodeExtensions() {
  local de=$1

  _creatDirIfNoExists $de

  code --list-extensions | xargs -L 1 echo code --install-extension > "${BASE_DIR}/environment/${de}/packages/vscode-extensions.txt"
  sleep 2
  echo
  echo "${green}${bold} VS Code extension list updated! ${nocolor}"
  echo
}

: '
 @method _updateCodeExtensions
 @return void
 @params {string} de
'
_creatDirIfNoExists() {
  local de=$1

  if [[ ! -d "${BASE_DIR}/environment/${de}/packages" ]]; then
    mkdir -p ${BASE_DIR}/environment/${de}/packages
  fi
}
