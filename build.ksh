#!/bin/ksh93
# This script is part of Copacabana's build system.
# Copyright (c) 2023: Pindorama
# C and C++ sanity checks by Samuel (callsamu), Lucas (volatusveritas)
# and Luiz Antônio Rangel (takusuman)
# This script is licenced under UUIC/NCSA (as Copacabana work itself).

set -e

progname="${0##*/}"
progdir="$(cd "$(dirname "$progname")"; pwd -P)"
trash="$(mktemp -d /tmp/CopaBuild.XXXXXX)"

# Task files
. "$progdir/build-system/internals/tasks/checks.ksh"
. "$progdir/build-system/internals/tasks/check_dependencies.ksh"

# Internal build system functions
. "$progdir/build-system/internals/helpers/helpers.shi"
. "$progdir/build-system/internals/helpers/posix-alt.shi"

rconfig "$progdir/build-system/machine.conf"
rconfig "$progdir/build-system/paths.conf"

(( FIX_VBOX_BUILD == 1 )) \
	&& { function nproc { echo 1; }; typeset -xf nproc; } 

check_elevate_method
check_dependencies
