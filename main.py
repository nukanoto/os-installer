#!/usr/bin/env python

import argparse, os, subprocess, shutil
from typing import Callable, List

programdir = os.getcwd()

steppath = "./.step"


def readstep() -> int:
    with open(steppath, encoding="utf-8", newline="\n") as f:
        return int(f.read())


def writestep(s: int):
    with open(steppath, "w", encoding="utf-8", newline="\n") as f:
        f.write(str(s))


def step(s: int, f: Callable, args: List = []):
    if s > readstep():
        f(*args)
        writestep(s)


def arch_setup():
    try:
        shutil.copytree(programdir, "/mnt/opt/os-installer", copy_function=shutil.copy2)
    except FileExistsError:
        shutil.rmtree("/mnt/opt/os-installer")
        arch_setup()


def arch_runscript(name: str, args: list[str] = []):
    subprocess.run(
        ["arch-chroot", "/mnt", "/opt/os-installer/{}.sh".format(name), *args]
    )


def runscript(name: str, args: list[str] = []):
    subprocess.run(["./{}.sh".format(name), *args])


parser = argparse.ArgumentParser()
parser.add_argument(
    "-d", "--drive", help="Specify the installation drive", type=str, required=True
)
parser.add_argument(
    "--no-encrypt", help="Don't encrypt the drive", action="store_false"
)
parser.add_argument(
    "--cpu", help="Specify the CPU vendor", choices=["amd", "intel"], required=True
)
parser.add_argument(
    "--gpu", help="Specify the GPU vendor", choices=["amd", "nvidia"], required=True
)
parser.add_argument(
    "-w", "--wireless", help="Install wireless drivers", action="store_true"
)
parser.add_argument(
    "-ds",
    "--display-server",
    help="Specify the display server (if you use the nvidia graphics card, force to use x11)",
    choices=["x11", "wayland"],
    default="wayland",
)
parser.add_argument(
    "-u", "--user", help="Specify the user name", type=str, required=True
)
parser.set_defaults(encrypt=True, wireless=False)

args = parser.parse_args()

args.encrypt = args.no_encrypt

if args.gpu == "nvidia":
    args.display_server = "x11"

# TODO: add no-enrypt mode

step(1, runscript, ["prepare_installation"])
step(2, runscript, ["make_partitions", [args.drive]])
step(
    3,
    runscript,
    ["mount_system", [args.drive]],
)
step(
    4,
    runscript,
    ["install_packages", [args.cpu, args.gpu, str(args.wireless), args.display_server]],
)

step(6, arch_setup)

step(7, arch_runscript, ["configure_system", [args.drive, args.user]])

with open("/mnt/opt/configure.sh", "w", encoding="utf-8", newline="\n") as f:
    f.write(
        """
#!/bin/bash

/opt/2_configure_system.sh
/opt/2_install_packages.sh {}
""".format(
            args.display_server
        )
    )
