#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

: '
  @method _configureOhMyZsh
  @return void
'
_configureOhMyZsh() {
  _omzInstall
  _zpluginInstall
  _configureTheme
  _setShellToZsh

  echo
  echo "${green}${bold} Oh My Zsh configured! ${nocolor}"
}

: '
  @method _omzInstall
  @return void
'
_omzInstall() {
  if [[ -d ~/.oh-my-zsh ]]; then
    sudo rm -rf ~/.oh-my-zsh
  fi

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

: '
  @method _configureTheme
  @return void
'
_configureTheme() {
  if [[ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    sudo rm -rf "$ZSH_CUSTOM/themes/spaceship-prompt"
  fi

  sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
  sudo ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  # sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/g' ~/.zshrc
}

: '
  @method _setShellToZsh
  @return void
'
_setShellToZsh() {
  if [[ $SHELL != '/usr/bin/zsh' ]]; then
    chsh -s `which zsh`
  fi
}

: '
  @method _zpluginInstall
  @return void
'
_zpluginInstall() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
}
