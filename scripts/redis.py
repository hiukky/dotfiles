#!/usr/bin/env python

import os
import time
from colorama import Fore, Style


def _install():
    print(f"\n{Fore.CYAN} R E D I S\n")

    print(f"{Fore.WHITE}")
    print("-> Installing...")

    if not os.popen("pacman -Qi redis 2>/dev/null").read():
        os.system("sudo pacman -S redis")
        time.sleep(1)

    print("-> Enabling...")
    os.system("sudo systemctl enable redis")
    os.system("sudo systemctl start redis")
    time.sleep(1)

    print(Style.RESET_ALL)
    print(f"{Fore.GREEN} Done!")