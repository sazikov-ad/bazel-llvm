#!/usr/bin/env python3

"""LLVM pre-built distribution file names."""

import platform
import sys

_known_distros = ["ubuntu", "arch", "manjaro", "debian", "fedora", "centos"]


def _major_llvm_version(llvm_version):
    return int(llvm_version.split(".")[0])


def _linux(llvm_version):
    arch = platform.machine()

    release_file_path = "/etc/os-release"
    with open(release_file_path) as release_file:
        lines = release_file.readlines()
        info = dict()
        for line in lines:
            line = line.strip()
            if not line:
                continue
            [key, val] = line.split('=', 1)
            info[key] = val
    if "ID" not in info:
        sys.exit("Could not find ID in /etc/os-release.")
    distname = info["ID"].strip('\"')

    if distname not in _known_distros:
        for distro in info["ID_LIKE"].strip('\"').split(' '):
            if distro in _known_distros:
                distname = distro
                break

    version = None
    if "VERSION_ID" in info:
        version = info["VERSION_ID"].strip('"')

    major_llvm_version = _major_llvm_version(llvm_version)

    if distname in _known_distros:
        if major_llvm_version < 11:
            os_name = "linux-gnu-ubuntu-18.04"
        else:
            os_name = "linux-gnu-ubuntu-20.04"
    else:
        sys.exit("Unsupported linux distribution and version: %s, %s" % (distname, version))

    return "clang+llvm-{llvm_version}-{arch}-{os_name}.tar.xz".format(
        llvm_version=llvm_version,
        arch=arch,
        os_name=os_name)


def main():
    """Prints the pre-built distribution file name."""

    if len(sys.argv) != 2:
        sys.exit("Usage: %s llvm_version" % sys.argv[0])

    llvm_version = sys.argv[1]

    system = platform.system()

    if system == "Linux":
        print(_linux(llvm_version))
        sys.exit()

    sys.exit("Unsupported system: %s" % system)


if __name__ == '__main__':
    main()
