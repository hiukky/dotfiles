import os
import time
from colorama import Fore, Style


def _install():
    print(f'{Fore.BLUE} R E D I S \n')

    print(f'{Fore.MAGENTA}')
    print('Installing...')
    if not os.popen('pacman -Qi redis 2>/dev/null').read():
        os.system('sudo pacman -S redis')
        time.sleep(1)

    print('Enabling...\n')
    os.system('sudo systemctl enable redis')
    os.system('sudo systemctl start redis')
    time.sleep(1)

    print(Style.RESET_ALL)
    print(f'{Fore.GREEN} Redis running...')
