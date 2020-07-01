#!/usr/bin/env python

import os
import re
import subprocess
from colorama import Fore, Style


def _dir():
    return os.getenv("BASE_DIR") + "/env/.packages/"


def _writeFile(name: str, data: str):
    if not os.path.isdir(_dir()):
        os.mkdir(_dir())

    open(_dir() + name, "w+").write(data)


def _writeNpmPkgList():
    print(f"\n{Fore.BLUE} N P M\n")

    print(f"{Fore.MAGENTA} Updating NPM Package List...\n")

    _writeFile(
        "npm-global.txt",
        re.sub(
            r"\├──|\/usr\/lib|\└──",
            "",
            os.popen("sudo npm list -g --depth 0 2>/dev/null").read().strip(),
        ),
    )

    print(f"{Fore.GREEN} Updated package list.")


def _writeSystemPkgList():
    print(f"\n{Fore.BLUE} S Y S T E M   P A C K A G E S\n")

    print(f"{Fore.MAGENTA} Updating System Package List ...\n")

    _writeFile(
        "pamac.txt",
        subprocess.Popen(
            "comm -23 <(pacman -Qqe | sort) <(pacman -Qqg base -g base-devel | sort | uniq)",
            shell=True,
            executable="/bin/bash",
            stdout=subprocess.PIPE,
        )
        .stdout.read()
        .decode("utf-8")
        .strip("\n"),
    )

    _writeFile(
        "snap.txt",
        os.popen("snap list | while read c1 c2; do echo $c1; done;")
        .read()
        .replace("Name", ""),
    )

    print(f"{Fore.GREEN} Updated package list.")


def _writeAll():
    _writeNpmPkgList()
    _writeSystemPkgList()
