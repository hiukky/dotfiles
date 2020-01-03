#! /bin/bash
source "${BASE_DIR}/scripts/utils/colors.sh"

# Config JSON
declare CONFIG=$(<"${BASE_DIR}/scripts/system/config.json")

: '
  @method _configure
  @return void
  @params {string} action - [copy | config]
'
_configure() {
  echo "Configuring..."
  local action=$1

  for obj in "$(echo ${CONFIG} | jq -r '.[]')"; do
    if [[  -n $obj  ]]; then
      local -a folders=$(echo $obj | jq -r '.folders')
      folders=(${folders//[\,\"\]\[]/""})

      if [[ -n folders ]]; then
        for folder in ${folders[@]}; do
          local path="$(echo $obj | jq -r '.path')"

          if [[ -d ~/"${path}/${folder}" ]]; then
            _execTask $action $path $folder
          fi
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
    "copy")
      _copyFilesToDotfiles $path $folder
    ;;

    "config") echo "Config";;

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
  if [[ -d "${BASE_DIR}/${path}/temp/${folder}" ]]; then
    rm -rf ${BASE_DIR}/${path}/temp/${folder}
  fi

  # # Copy new settings
  mkdir -p ${BASE_DIR}/temp/${path}
  cp -avr ~/temp/${path}/${folder} ${BASE_DIR}/temp/${path}
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
  cp -avr ${BASE_DIR}/${path}/${folder} ~/${path}
}

_configure
