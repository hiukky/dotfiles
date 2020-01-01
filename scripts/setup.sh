#! /bin/bash
readonly BINPATH=$(pwd)

# Imports
source "${BINPATH}/utils/colors.sh"

# CLI
declare OPTIONS=(
  "[1] - Install Packages"
  "[2] - Uninstall Packages"
  "[3] - Update Package List"
  "[3] - Mount Partition"
)

echo
echo "${aqua}${bold}-------------------- SETUP OPTIONS --------------------${nocolor}"
echo
printf '%s\n' "${green}${bold}${OPTIONS[@]}${nocolor}"
echo

: '
  @method _imports

  @return void
'
_imports(){
  source "${BINPATH}/packages/manager.sh"
}

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
  _imports

  case $option in

  1) _install;;

  2) _uninstall;;

  3) _updatePkgList;;

  *) echo "Invalid";;
  esac
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

