#!/usr/bin/env python

import os
import re
import subprocess
from colorama import Fore, Style


def _dir():
    return os.environ["HOME"] + "/.packages/"


def _writeFile(name: str, data: str):
    if not os.path.isdir(_dir()):
        os.mkdir(_dir())

    open(_dir() + name, "w+").write(data)


def _syncNpmPkgs():
    print(f"\n{Fore.CYAN} N P M\n")

    print(f"{Fore.WHITE} Updating NPM Package List ...\n")

    _writeFile(
        "npm-global",
        re.sub(
            r"\├──|\/usr\/lib|\└──",
            "",
            os.popen("sudo npm list -g --depth 0 2>/dev/null").read().strip(),
        ),
    )

    print(f"{Fore.GREEN} Done!")


def _syncSystemPkgs():
    print(f"\n{Fore.CYAN} S Y S T E M   P A C K A G E S\n")

    print(f"{Fore.WHITE} Updating System Package List ...\n")

    _writeFile(
        "pamac",
        subprocess.Popen(
            "comm -23 <(pacman -Qqe | sort) <(pacman -Qqg base -g base-devel  2>/dev/null | sort | uniq)",
            shell=True,
            executable="/bin/bash",
            stdout=subprocess.PIPE,
        )
        .stdout.read()
        .decode("utf-8")
        .strip("\n"),
    )

    _writeFile(
        "snap",
        os.popen("snap list | while read c1 c2; do echo $c1; done;")
        .read()
        .replace("Name", ""),
    )

    print(f"{Fore.GREEN} Done!")


def _syncAllPkgs():
    _syncNpmPkgs()
    _syncSystemPkgs()
