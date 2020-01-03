#! /bin/bash
readonly BASE_DIR="$(pwd)"

# Imports
source "${BASE_DIR}/scripts/utils/colors.sh"
source "${BASE_DIR}/scripts/packages/manager.sh"
source "${BASE_DIR}/scripts/system/mnt.sh"
source "${BASE_DIR}/scripts/system/configure.sh"

# CLI
declare OPTIONS=(
  "[1] - Install Packages"
  "[2] - Uninstall Packages"
  "[3] - Update Package List"
  "[4] - Mount Partition"
  " "
  "${orange}${bold}[dot -u] - Update Dotfiles${nocolor}"
  "${orange}${bold}[sys -c] - Configure System${nocolor}"
)

echo
echo "${purple}${bold}-------------------- SETUP OPTIONS --------------------${nocolor}"
echo
printf '%s\n' "${aqua}${bold}${OPTIONS[@]}${nocolor}"
echo

: '
  @method _question
  @return string
'
_question() {
  read -p "Escolha uma opção: " option
  echo "$option"
}

: '
 @method _runTask
 @params {number} option
 @return void
'
_runTask() {
  case $option in
  1) _installPkgs;;

  2) _uninstallPkgs;;

  3) _updatePkgList;;

  4) _mountPartition;;

  "dot -u") _configure "copy";;

  "sys -c") _configureSys;;

  *) echo "Invalid";;
  esac
}

: '
  @method _configureSys
  @return void
'
_configureSys() {
  # Remove outdated packages
  #_uninstall

  # Install personal packages
  #_install

  # Mount partition
  #_mountPartition

  # Copy dotfiles
  _configure "config"

  exit 0
}

: '
 @method _runTask
 @return void
'
_init() {
  local option=$( _question )
  echo "[$option]"
  if [[ "${OPTIONS[*]}" != *"[$option]"* ]]; then
    echo
    echo "${red}${bold}Invalid option!${nocolor}"
    option=$( _question )
  fi

  _runTask $option
}

_init

