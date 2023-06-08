#!/bin/ksh93
# This script is the head of Copacabana's build system.
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA

set -e

progname="${0##*/}"
progdir="$(cd "$(dirname "$progname")"; pwd -P)"
trash="$(mktemp -d /tmp/CopaBuild.XXXXXX)"

# Task files
. "$progdir/build-system/internals/tasks/platform_checks.ksh"
. "$progdir/build-system/internals/tasks/check_dependencies.ksh"

# Internal build system functions
. "$progdir/build-system/internals/helpers/helpers.shi"
. "$progdir/build-system/internals/helpers/posix-alt.shi"

rconfig "$progdir/build-system/machine.conf"
rconfig "$progdir/build-system/paths.conf"

platform_checks
(( FIX_VBOX_BUILD == 1 )) \
	&& { function nproc { echo 1; }; typeset -xf nproc; } 
check_elevate_method
check_dependencies
