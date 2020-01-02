#! /bin/bash
source "${BINPATH}/utils/colors.sh"

declare CONFIG=$(<config.json)

_configure(){
  echo "Configuring..."

  for row in "$(echo ${CONFIG} | jq -r '.[]')"; do
    echo $row | jq '.path'
  done
}

_configure
