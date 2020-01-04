#! /bin/bash
readonly BASE_DIR="$(pwd)"

# Imports
source "${BASE_DIR}/scripts/utils/colors.sh"
source "${BASE_DIR}/scripts/packages/manager.sh"
source "${BASE_DIR}/scripts/system/mnt.sh"
source "${BASE_DIR}/scripts/system/configure.sh"

# CLI
declare OPTIONS=(
  "${purple}${bold}TOOLS${nocolor}"
  "  ${aqua}${bold}System${nocolor}"
  "    p -i     - Install Packages"
  "    p -r     - Uninstall Packages"
  "    p -ul    - Update Packages List"
  "    omz -c   - Configure Oh My Zsh"
  " "
  "  ${aqua}${bold}NPM${nocolor}"
  "    n -i     - Install Packages"
  "    n -u     - Update Packages List"
  " "
  "${purple}${bold}SYSTEM${nocolor}"
  "    sys -mnt - Mount Partition"
  " "
  "    ${orange}${bold}dot -u   - Update Dotfiles${nocolor}"
  "    ${orange}${bold}sys -c   - Complete System Setup${nocolor}"
)

: '
  @method _showSetupOptions
  return void
'
_showSetupOptions() {
  echo
  echo "${orange}${bold}-------------------- DOTFILES OPTIONS --------------------${nocolor}"
  echo
  printf '%s\n' "${aqua}${bold}${OPTIONS[@]}${nocolor}"
  echo
}

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
    # System
    'p -i') _installPkgs;;
    'p -r') _uninstallPkgs;;
    'p -ul') _updatePkgList;;
    'omz -c') _configureOhMyZsh;;
    'sys -mnt') _mountPartition;;
    "dot -u") _configure "copy";;
    "sys -c") _configureSys;;

    # NPM
    'n -i') _installNpmPkgs;;
    'n -u') _updateNpmPkgList;;

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

  # Mount partition
  _mountPartition

  # Configure ZSH
  _configureOhMyZsh

  # Copy dotfiles
  _configure "config"

  echo
  echo "${green}${bold} System Configuration completed.! ${nocolor}"
  echo "${orange}${bold} Restarting... ${nocolor}"
  sleep 4
  exit 0
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

