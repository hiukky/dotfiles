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
  local files="$(echo ${CONFIG} | jq -r '.files')"
  files=(${files//[\,\"\]\[]/""})

  if [[ -n ${files} ]]; then
    for file in ${files[@]}; do
      _execTask $action $path $folder $de "file"
    done
  fi
}

: '
  @method _configure
  @return void
  @params {string} action - [copy | config]
  @params {string} path
  @params {string} folder
  @params {string} de
  @params {string} type
'
_execTask() {
  local type="$5"

  case $action in
    "copy") _copyFilesToDotfiles $path $folder $de $type;;
    "config") _copyFilesToSystem $path $folder $de $type;;
    *) echo "${red}${bold}Invalid option!${nocolor}";;
  esac
}

: '
  @method _copyFilesToDotfiles
  @return void
  @params {string} path
  @params {string} folder
  @params {string} de
  @params {string} type
'
_copyFilesToDotfiles() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/Documentos/Github/dotfiles/temp/.config/xfce4"
  '

  case $type in
    'dir')
      if [[ -d "${BASE_DIR}/environment/${de}/${path}/${folder}" ]]; then
        rm -rf ${BASE_DIR}/environment/${de}/${path}/${folder}
      fi

      # Copy new settings
      mkdir -p ${BASE_DIR}/environment/${de}/${path}
      cp -avr ~/${path}/${folder} ${BASE_DIR}/environment/${de}/${path}
    ;;

    'file')
      if [[ -f "${BASE_DIR}/environment/${de}/${file}" ]]; then
        rm -rf ${BASE_DIR}/environment/${de}/${file}
      fi

      # Copy new settings
      cp -avr ~/${file} ${BASE_DIR}/environment/${de}
    ;;
  esac
}

: '
  @method _copyFilesToSystem
  @return void
  @params {string} path
  @params {string} folder
  @params {string} de
  @params {string} type
'
_copyFilesToSystem() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/.config/xfce4"
  '
    case $type in
    'dir')
      if [[ -d "~/${path}/${folder}" ]]; then
        rm -rf ~/${path}/${folder}
      fi

      # Copy new settings
      cp -avr ${BASE_DIR}/environment/${de}/${path}/${folder} ~/${path}
    ;;

    'file')
      if [[ -f "~/${file}" ]]; then
        rm -rf ~/${file}
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
  # Download
  if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Set default shell
  if [[ $SHELL != '/usr/bin/zsh' ]]; then
    chsh -s `which zsh`
  fi

  # Download theme
  if [[ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
    sudo ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="spaceship"/g' ~/.zshrc
  fi

  sleep 2
  echo
  echo "${green}${bold} Oh My Zsh configured! ${nocolor}"
}
