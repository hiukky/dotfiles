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

  for obj in "$(echo ${CONFIG} | jq -r '.[]')"; do
    if [[  -n $obj  ]]; then
      local -a folders=$(echo $obj | jq -r '.folders')
      folders=(${folders//[\,\"\]\[]/""})

      if [[ -n folders ]]; then
        for folder in ${folders[@]}; do
          local path="$(echo $obj | jq -r '.path')"

          _execTask $action $path $folder $de
        done
      fi
    fi
  done
}

: '
  @method _configure
  @return void
  @params {string} action - [copy | config]
  @params {string} path
  @params {string} folder
'
_execTask() {
  case $action in
    "copy") _copyFilesToDotfiles $path $folder $de;;
    "config") _copyFilesToSystem $path $folder $de;;
    *) echo "Invalid";;
  esac
}

: '
  @method _copyFilesToDotfiles
  @return void
  @params {string} path
  @params {string} folder
'
_copyFilesToDotfiles() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/Documentos/Github/dotfiles/temp/.config/xfce4"
  '
  if [[ -d "${BASE_DIR}/environment/${path}/${folder}" ]]; then
    rm -rf ${BASE_DIR}/environment/${de}/${path}/${folder}
  fi

  # # Copy new settings
  mkdir -p ${BASE_DIR}/${path}
  cp -avr ~/${path}/${folder} ${BASE_DIR}/environment/${de}/${path}
}

: '
  @method _copyFilesToSystem
  @return void
  @params {string} path
  @params {string} folder
'
_copyFilesToSystem() {
  : '
    Remove existing directory

    @example dir "/home/hiukky/.config/xfce4"
  '
  rm -rf ~/${path}/${folder}

  # Copy new settings
  cp -avr ${BASE_DIR}/environment/${de}/${path}/${folder} ~/${path}
}
