#! /bin/bash
source "$BASE_DIR/scripts/utils/colors"

'
  @function _configureRedis
'
_configureRedis() {
  echo "${aqua}${bold}Configuring Redis Server...${nocolor}"

  if [[ -z "$(pacman -Qi redis 2>/dev/null)" ]]; then
    sudo pacman -S redis
  fi

  sudo systemctl enable redis
  sudo systemctl start redis

  sleep 2
  echo "${green}${bold}Redis Server started!${nocolor}"
  echo
}
