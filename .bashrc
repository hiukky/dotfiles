#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0222222" #black
    echo -en "\e]P1803232" #darkred
    echo -en "\e]P25b762f" #darkgreen
    echo -en "\e]P3aa9943" #brown
    echo -en "\e]P4324c80" #darkblue
    echo -en "\e]P5706c9a" #darkmagenta
    echo -en "\e]P692b19e" #darkcyan
    echo -en "\e]P7ffffff" #lightgray
    echo -en "\e]P8222222" #darkgray
    echo -en "\e]P9982b2b" #red
    echo -en "\e]PA89b83f" #green
    echo -en "\e]PBefef60" #yellow
    echo -en "\e]PC2b4f98" #blue
    echo -en "\e]PD826ab1" #magenta
    echo -en "\e]PEa1cdcd" #cyan
    echo -en "\e]PFdedede" #white
    clear
fi
complete -C /usr/local/bin/bitcomplete bit
