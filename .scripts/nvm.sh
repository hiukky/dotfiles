#!/bin/bash

set -eE

printf "\n\nNVM \n\n"

printf "\n\nDownloading dependencies... \n\n"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | zsh

printf "\n\nDone! \n\n"
