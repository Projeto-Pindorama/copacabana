#!/bin/ksh93
# This script is part of Copacabana's build system.
# Copyright (c) 2023: Luiz Antônio Rangel (takusuman)
# This script is licenced under UUIC/NCSA (as Copacabana work itself).

set -e

progname="${0##*/}"
progdir="$(cd "$(dirname "$0")"; pwd -P)"

. "$progdir/build-system/internals/helpers.shi"
. "$progdir/build-system/internals/posix-alt.shi"

rconfig $progdir/build-system/machine.conf

# TODO: Write the build system itself, and a way to run Alambiko's pkgbuild
# scripts.
