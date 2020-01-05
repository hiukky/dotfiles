#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

# DE's
declare ENVS=(
  "[de -x] - xfce"
  "[de -g] - gnome"
)

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
  @method _configure
  @return void
  @params {string} action - [copy | config]
'
_configure() {
  local action=$1

  _showDEOptions
  local de=$( _selectDE )

  declare CONFIG=$(<"${BASE_DIR}/environment/${de}/config.json")

  # Directories
  local directories="$(echo ${CONFIG} | jq -r '.directories'| jq -r 'map("\(.path):\(.folders)")' | jq '.[]')"

  while read -r obj; do
    IFS=':' read -r path folders <<< $obj

    folders=(${folders//[\,\"\]\[]/' '})

    if [[ -n $path ]] && [[ -n $folders ]]; then
      for folder in "${folders[@]}"; do
        _execTask $action $path $folder $de "dir"
      done
    fi

  done <<< "$(echo $directories | jq -r),"

  # Files
  local files="$(echo ${CONFIG} | jq -r '.files'| jq -r 'map("\(.path):\(.files_name)")' | jq '.[]')"

  while read -r obj; do
    IFS=':' read -r path files_name <<< $obj

    files_name=(${files_name//[\,\"\]\[]/' '})

    if [[ -n $path ]] && [[ -n $files_name ]]; then
      for file_name in "${files_name[@]}"; do
        _execTask $action $path $file_name $de "file"
      done
    fi

  done <<< "$(echo $files | jq -r),"

  # Dotfiles
  local dotfiles="$(echo ${CONFIG} | jq -r '.dotfiles')"
  dotfiles=(${dotfiles//[\,\"\]\[]/""})

  if [[ -n ${dotfiles} ]]; then
    for file in ${dotfiles[@]}; do
      _execTask $action $path $file $de "dotfile"
    done
  fi
}

: '
  @method _configure
  @return void
  @params {string} $1 action - [copy | config]
  @params {string} $2 path
  @params {string} $3 folder | files
  @params {string} $4 de
  @params {string} $5 type
'
_execTask() {
  local action="$1"
  local path="$2"
  local folderOrFiles="$3"
  local de="$4"
  local type="$5"

  case $action in
    "copy") _copyFilesToDotfiles $path $folderOrFiles $de $type;;
    "config") _copyFilesToSystem $path $folderOrFiles $de $type;;
    *) echo "${red}${bold}Invalid option!${nocolor}";;
  esac
}

: '
  @method _copyFilesToDotfiles
  @return void
  @params {string} $1 path
  @params {string} $2 folder
  @params {string} $3 de
  @params {string} $4 type
'
_copyFilesToDotfiles() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/Documentos/Github/dotfiles/temp/.config/xfce4"
  '
  local path="$1"
  local de="$3"
  local type="$4"

  case $type in
    'dir' | 'file')
      local folderOrFiles="$2"

      if [[ -d "${BASE_DIR}/environment/${de}/${path}/${folderOrFiles}" ]]; then
        rm -rf ${BASE_DIR}/environment/${de}/${path}/${folderOrFiles}
      fi

      # Copy new settings
      mkdir -p ${BASE_DIR}/environment/${de}/${path}
      cp -avr ~/${path}/${folderOrFiles} ${BASE_DIR}/environment/${de}/${path}
    ;;

    'dotfile')
      local dotfile="$2"

      if [[ -f "${BASE_DIR}/environment/${de}/${dotfile}" ]]; then
        rm -rf ${BASE_DIR}/environment/${de}/${dotfile}
      fi

      # Copy new settings
      cp -avr ~/${dotfile} ${BASE_DIR}/environment/${de}
    ;;
  esac
}

: '
  @method _copyFilesToSystem
  @return void
  @params {string} $1 path
  @params {string} $2 folder
  @params {string} $3 de
  @params {string} $4 type
'
_copyFilesToSystem() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/.config/xfce4"
  '
  local path="$1"
  local de="$3"
  local type="$4"

    case $type in
    'dir' | 'file')
      local folderOrFiles="$2"

      if [[ -d "~/${path}/${folderOrFiles}" ]]; then
        rm -rf ~/${path}/${folderOrFiles}
      fi

      # Copy new settings
      cp -avr ${BASE_DIR}/environment/${de}/${path}/${folderOrFiles} ~/${path}
    ;;

    'dotfile')
      local dotfile="$2"

      if [[ -f "~/${dotfile}" ]]; then
        rm -rf ~/${dotfile}
      fi

      # Copy new settings
      cp -avr ${BASE_DIR}/environment/${de}/${file} ~/
    ;;
  esac
}

: '
  @method _configureOhMyZsh
  @return void
'
_configureOhMyZsh() {
  _downloadOhMyZsh
  _configureOhMyZshTheme
  _setShellToZsh

  echo
  echo "${green}${bold} Oh My Zsh configured! ${nocolor}"
}

: '
  @method _downloadOhMyZsh
  @return void
'
_downloadOhMyZsh() {
  if [[ -d ~/.oh-my-zsh ]]; then
    sudo rm -rf ~/.oh-my-zsh
  fi

  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

: '
  @method _configureOhMyZshTheme
  @return void
'
_configureOhMyZshTheme() {
  if [[ -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    sudo rm -rf "$ZSH_CUSTOM/themes/spaceship-prompt"
  fi

  sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
  sudo ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
  sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/g' ~/.zshrc
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
