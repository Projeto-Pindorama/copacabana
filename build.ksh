#!/usr/bin/env ksh93
# This script is the head of Copacabana's build system.
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA

set -e

progname="${0##*/}"
progdir="$(cd "$(dirname "$progname")"; pwd -P)"

# Immediatly source and run the platform checks before doing anything else.
. "$progdir/build-system/tasks/platform_checks.ksh"; platform_checks

# Internal build system functions
. "$progdir/build-system/internals/helpers/helpers.shi"
. "$progdir/build-system/internals/helpers/posix-alt.shi"

# Task files
. "$progdir/build-system/tasks/check_dependencies.ksh"
. "$progdir/build-system/tasks/disk_managenment.ksh"
. "$progdir/build-system/tasks/get_source-code.ksh"
. "$progdir/build-system/tasks/build_all.ksh"

. "$progdir/build-system/tasks/finish.ksh"

rconfig "$progdir/build-system/machine.ini"
rconfig "$progdir/build-system/work.ini"
rconfig "$progdir/build-system/fhs.ini"

trash="$(mktemp -d "$TRASH_PREFIX/CopaBuild.XXXXXX")"

map dtime initial "$(date +'%Hh%Mmin on %B %d, %Y')" 

check_elevate_method
check_dependencies
create_disk "$DISK_BLOCK"
populate
get_sources sources.txt sources.sha256
build cross-tools cross/mussel
#build cross-tools "base/kernel-headers" "dev/GNUBinutils" \
#	"dev/GNUcc" "base/LibC" "dev/GNUcc"

#build tools "base/kernel-headers" "dev/GNUBinutils" \
#	"dev/GNUcc" "base/LibC" "dev/GNUcc"

#build base "base/kernel-headers" "dev/GNUBinutils" \
#	"dev/GNUcc" "base/LibC" "dev/GNUcc"
build close
finish
