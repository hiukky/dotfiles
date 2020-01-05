#! /bin/bash
readonly BASE_DIR="$(pwd)"

# Imports
source "${BASE_DIR}/scripts/utils/colors.sh"
source "${BASE_DIR}/scripts/packages/manager.sh"
source "${BASE_DIR}/scripts/system/mnt.sh"
source "${BASE_DIR}/scripts/system/configure.sh"

# CLI
declare -a OPTIONS=(
  " ${green}${bold}D o t f i l e s${nocolor}"
  " "
  "   ${aqua}${bold}Tools${nocolor}"
  " "
  "     ${orange}${bold}dot --u-spl    : Update System Packages List${nocolor}"
  "     ${orange}${bold}dot --u-npl    : Update NPM Packages List${nocolor}"
  "     ${orange}${bold}dot --u-vse    : Update VS Code Extensions List${nocolor}"
  " "
  "     ${purple}${bold}dot -u         : Update Dotfiles${nocolor}"
  " "
  " ${green}${bold}S y s t e m${nocolor}"
  " "
  "   ${aqua}${bold}Tools${nocolor}"
  " "
  "     ${orange}${bold}sys --i-spl    : Install System Packages${nocolor}"
  "     ${orange}${bold}sys --r-spl    : Uninstall System Packages${nocolor}"
  "     ${orange}${bold}sys --mnt      : Mount Partition${nocolor}"
  "     ${orange}${bold}sys --c-omz    : Configure Oh My Zsh${nocolor}"
  "     ${orange}${bold}sys --i-npl    : Install NPM Packages${nocolor}"
  "     ${orange}${bold}sys --i-vse    : Install VS Code Extensions${nocolor}"

  " "
  "     ${purple}${bold}sys -c         : Complete System Setup${nocolor}"
  " "
)

: '
  @method _showSetupOptions
  return void
'
_showSetupOptions() {
  echo
  echo "${orange}${bold}-------------------- D O T F I L E S   O P T I O N S --------------------${nocolor}"
  echo
  printf '%s\n' "${aqua}${bold}${OPTIONS[@]}${nocolor}"
  echo
}

: '
  @method _question
  @return string
'
_question() {
  read -p "Select an option: " option
  echo "$option"
}

: '
 @method _runTask
 @params {number} option
 @return void
'
_runTask() {
  case $option in
    # Dotfiles
    'dot --u-spl') _updatePkgList;;
    'dot --u-npl') _updateNpmPkgList;;
    'dot --u-vse') _updateCodeExtensions;;

    "dot -u") _configure "copy";;

    # System
    'sys --i-spl') _installPkgs;;
    'sys --r-spl') _uninstallPkgs;;
    'sys --mnt') _mountPartition;;
    'sys --c-omz') _configureOhMyZsh;;
    'sys --i-npl') _installNpmPkgs;;
    'sys --i-vse') _installCodeExtensions;;

    "sys -c") _configureSys;;

    *) echo "${red}${bold}Invalid option!${nocolor}";;
  esac
}

: '
  @method _configureSys
  @return void
'
_configureSys() {
  # Remove outdated packages
  _uninstallPkgs

  # Install personal packages
  _installPkgs

  # Install NPM Packages
  _installNpmPkgs

  # Install VS Code extensions
  _installCodeExtensions

  # Mount partition
  _mountPartition

  # Configure ZSH
  _configureOhMyZsh

  # Copy dotfiles
  _configure "config"

  # Configure ZSH
  _configureOhMyZsh &
  sleep 5
  echo
  echo "${green}${bold} System Configuration completed.! ${nocolor}"
  echo "${orange}${bold} Restarting... ${nocolor}"
  sleep 4
  reboot
}

: '
 @method _runTask
 @return void
'
_init() {
  _showSetupOptions
  local option=$( _question )

  if [[ "${OPTIONS[*]}" != *"$option"* ]]; then
    echo
    echo "${red}${bold}Invalid option!${nocolor}"
    option=$( _question )
  fi

  _runTask $option
}

_init

