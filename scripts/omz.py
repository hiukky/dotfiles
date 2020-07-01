#!/usr/bin/env python

import os
from colorama import Fore, Style


def _install():
    print(f"\n{Fore.CYAN} O H  M Y  Z S H\n")

    _omz()
    _znit()
    _theme()
    _setShell()

    print(f"{Fore.GREEN} Done!")


def _omz():
    print(f"{Fore.WHITE} Installing Oh My Zsh ...")

    if os.path.isdir("~/.oh-my-zsh"):
        os.system("sudo rm -rf ~/.oh-my-zsh")
        os.system(
            'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
        )


def _znit():
    print(f"{Fore.WHITE} Installing Znit ...")

    os.system(
        'sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"'
    )


def _theme():
    print(f"{Fore.WHITE} Installing Spaceship theme ...")

    if os.path.isdir("$ZSH_CUSTOM/themes/spaceship-prompt"):
        os.system('sudo rm -rf "$ZSH_CUSTOM/themes/spaceship-prompt"')
        os.system(
            'sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"'
        )
        os.system(
            'sudo ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"'
        )


def _setShell():
    if os.popen("$SHELL").read() != "/usr/bin/zsh":
        os.system("chsh -s `which zsh`")
