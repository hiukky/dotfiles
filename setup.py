import os
from colorama import Fore, Style

from scripts import redis, omz


class Setup():
    def __init__(self):
        self.option = ''
        self.options = {
            'dt -i redis': redis._install,
            'dt -i omz': omz._install
        }

        self._boot()

    def _boot(self):
        print(f'\n{Fore.YELLOW} ------------------ DOTFILES ------------------ \n')
        print(
            f'{Fore.YELLOW} dt -i redis {Style.RESET_ALL}         -> Install Redis Server')
        print(
            f'{Fore.YELLOW} dt -i omz {Style.RESET_ALL}           -> Install Oh My Zsh\n')

        try:
            while not self.option or not self.option in self.options:
                self._question()

            self.options[self.option]()
        except:
            exit()

    def _question(self):
        self.option = input(
            f'{Fore.YELLOW} Select an option: {Style.RESET_ALL}')


Setup()
