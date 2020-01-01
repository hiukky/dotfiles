#! /bin/bash
readonly BINPATH="$(pwd)/scripts"

# Imports
source "${BINPATH}/utils/colors.sh"
source "${BINPATH}/packages/manager.sh"
source "${BINPATH}/system/mnt.sh"
source "${BINPATH}/system/configure.sh"

# CLI
declare OPTIONS=(
  "[1] - Install Packages"
  "[2] - Uninstall Packages"
  "[3] - Update Package List"
  "[4] - Mount Partition"
  " "
  "${orange}${bold}[0] - Mount System${nocolor}"
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
_question(){
  read -p "Escolha uma opção: " option
  echo "$option"
}

: '
 @method _runTask

 @params {Number} option

 @return void
'
_runTask(){
  case $option in
  0) _configureSys;;

  1) _install;;

  2) _uninstall;;

  3) _updatePkgList;;

  4) _mountPartition;;

  *) echo "Invalid";;
  esac
}

: '
  @method _configureSys

  @return void
'
_configureSys() {
  # Remove outdated packages
  _uninstall

  # Install personal packages
  _install

  # Mount partition
  _mountPartition

  # Copy dotfiles
  _configure

  exit 0
}

: '
 @method _runTask

 @return void
'
_init(){
  local option=$( _question )

  if [[ "${OPTIONS[*]}" != *"[$option]"* ]]; then
    echo
    echo "${red}${bold}Invalid option!${nocolor}"
    option=$( _question )
  fi

  _runTask $option
}

_init

