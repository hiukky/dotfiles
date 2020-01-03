#! /bin/bash
source "${BINPATH}/utils/colors.sh"

declare CONFIG=$(<config.json)

_configure(){
  echo "Configuring..."

  for obj in "$(echo ${CONFIG} | jq -r '.[]')"; do
    if [[  -n $obj  ]]; then
      local -a folders=$(echo $obj | jq -r '.folders')
      folders=(${folders//[\,\"\]\[]/""})

      if [[ -n folders ]]; then
        for folder in ${folders[@]}; do
          if [[ -d ~/"$(echo $obj | jq -r '.path')/${folder}" ]]; then
            echo "Delete old folders in home and copy settings."
          fi
        done
      fi
    fi
  done
}

_configure
