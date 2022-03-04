#!/usr/bin/env python

import argparse, os, subprocess, shutil

programpath = os.getcwd()
programdir = os.path.dirname(programpath)


def arch_setup():
    shutil.copytree(programdir, "/mnt/opt/os-installer", copy_function=shutil.copy2)


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
    args.display_server = "wayland"

# TODO: add no-enrypt mode

runscript("make_partitions", [args.drive])
runscript("mount_system", [args.cpu, args.gpu, args.wireless, args.display_server])
runscript("install_packages", [args.cpu, args.gpu, args.wireless, args.display_server])

arch_setup()

arch_runscript("configure_system", [args.user])

with open("/mnt/opt/configure.sh", "x", encoding="utf-8", newline="\n") as f:
    f.write(
        """
#!/bin/bash

/opt/2_configure_system.sh
/opt/2_install_packages.sh {}
""".format(
            args.display_server
        )
    )
