#!/usr/bin/env python

import os
from colorama import Fore, Style

from scripts import redis, omz, packages


os.environ["BASE_DIR"] = os.getcwd()


class Setup:
    def __init__(self):
        self.option = ""
        self.options = {
            "i redis": redis._install,
            "i omz": omz._install,
            "i -pkg npm": packages._writeNpmPkgList,
            "u -pkg sys": packages._writeSystemPkgList,
            "u -pkg -all sys": packages._writeAll,
        }

        self._boot()

    def _boot(self):
        print(f"\n{Fore.YELLOW} ------------------ DOTFILES ------------------ \n")
        print(f"\n{Fore.CYAN} I N S T A L L \n")
        print(
            f"{Fore.GREEN} i redis {Style.RESET_ALL}            -> Install Redis Server"
        )
        print(f"{Fore.GREEN} i omz {Style.RESET_ALL}              -> Install Oh My Zsh")
        print(f"\n{Fore.CYAN} U P D A T E \n")
        print(
            f"{Fore.GREEN} u -pkg npm {Style.RESET_ALL}         -> Update NPM packages list"
        )
        print(
            f"{Fore.GREEN} u -pkg sys {Style.RESET_ALL}         -> Update System packages list"
        )
        print(
            f"{Fore.GREEN} u -pkg -all sys {Style.RESET_ALL}    -> Update All packages list\n"
        )

        try:
            while not self.option or not self.option in self.options:
                self._question()

            self.options[self.option]()
        except:
            exit()

    def _question(self):
        self.option = input(f"{Fore.YELLOW} Select an option: {Style.RESET_ALL}")


Setup()
