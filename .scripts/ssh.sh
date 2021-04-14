#!/bin/bash

set -eE

printf "\n\nGITHUB \n\n"

ssh-keygen -t ed25519 -C "developermarsh@gmail.com" -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

printf "\n\nDone! Add the public key to the Github account. \n\n"

cat ~/.ssh/id_ed25519.pub
