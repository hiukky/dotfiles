#! /bin/bash
readonly BASE_DIR="$(pwd)"

# Imports
source "${BASE_DIR}/scripts/utils/colors.sh"
source "${BASE_DIR}/scripts/packages/manager.sh"
source "${BASE_DIR}/scripts/system/mnt.sh"
source "${BASE_DIR}/scripts/system/configure.sh"
source "${BASE_DIR}/scripts/system/ohMyZsh.sh"

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

# DE's
declare ENVS=(
  "[de -x] - xfce"
  "[de -g] - gnome"
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
  @method _showDEOptions
  return void
'
_showDEOptions() {
  echo
  printf '%s\n' "${green}${bold}${ENVS[@]}${nocolor}"
  echo
}

: '
  @method _selectOption
  @return string
'
_selectOption() {
  read -p "Select an option: " option
  echo "$option"
}

: '
  @method _selectDE
  @return string
'
_selectDE() {
  read -p "Select your DE: " de

  if [[ "${ENVS[*]}" != *"[${de}]"* ]]; then
    echo
    echo "${red}${bold}Invalid option!${nocolor}"
    read -p "Select your DE: " de
  fi

  case $de in
    'de -x') de='xfce';;
    'de -g') de='gnome';;
    *) exit
  esac

  echo "$de"
}

: '
 @method _runTask
 @params {number} option
 @return void
'
_runTask() {
  _showDEOptions
  local de=$( _selectDE )

  case $option in
    # Dotfiles
    'dot --u-spl') _updatePkgList $de;;
    'dot --u-npl') _updateNpmPkgList $de;;
    'dot --u-vse') _updateCodeExtensions $de;;

    "dot -u") _updateDotfiles $de;;

    # System
    'sys --i-spl') _installPkgs $de;;
    'sys --r-spl') _uninstallPkgs $de;;
    'sys --mnt') _mountPartition ;;
    'sys --c-omz') _configureOhMyZsh $de;;
    'sys --i-npl') _installNpmPkgs $de;;
    'sys --i-vse') _installCodeExtensions $de;;

    "sys -c") _configureSys $de;;

    *) echo "${red}${bold}Invalid option!${nocolor}";;
  esac
}

: '
  @method _updateDotfiles
  @return void
  @param {string} de
'
_updateDotfiles() {
  local de=$1

  # Copy config
  _configure "copy" $de

  # Update system packages list
  _updatePkgList $de

  # Update NPM packages list
  _updateNpmPkgList $de

  # Update VS code extensions
  _updateCodeExtensions $de

  sleep 10
  echo
  echo "${green}${bold} Dotfiles Updated! ${nocolor}"
  echo
}

: '
  @method _configureSys
  @return void
  @param {string} de
'
_configureSys() {
  local de=$1

  # Remove outdated packages
  _uninstallPkgs $de

  # Install personal packages
  _installPkgs $de

  # Install NPM Packages
  _installNpmPkgs $de

  # Install VS Code extensions
  _installCodeExtensions $de

  # Mount partition
  _mountPartition

  # Copy dotfiles
  _configure "config" $de

  # Configure ZSH
  _configureOhMyZsh &
  sleep 10
  echo
  echo "${green}${bold} System Configuration completed! ${nocolor}"
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
  local option=$( _selectOption )

  if [[ "${OPTIONS[*]}" != *"$option"* ]]; then
    echo
    echo "${red}${bold}Invalid option!${nocolor}"
    option=$( _selectOption )
  fi

  _runTask $option
}

_init

