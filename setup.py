import os
from colorama import Fore, Style
import scripts

print(f'\n{Fore.YELLOW} ------------------ DOTFILES ------------------ \n')
print(f'{Fore.BLUE} dt -i redis         -> Install Redis Server\n')


def _execFunction(option: str):
    options = {
        'dt -i redis': scripts.redis._install,
    }

    if option in options:
        options[option]()
    else:
        print('Invalid option.')


def _init():
    option = ''

    while not option:
        option = input(f'{Fore.MAGENTA} Select an option: {Style.RESET_ALL}')

    _execFunction(option)


_init()
