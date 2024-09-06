#!/usr/bin/env ksh93
# This script is the head of Copacabana's build system.
# Copyright (c) 2023-2024: Pindorama
# SPDX-Licence-Identifier: NCSA

set -e

progname="${0##*/}"
progdir="$(cd "$(dirname "$progname")"; pwd -P)"

# _make
tasks="$progdir/build-system/tasks"
made="$progdir/_made"
. "$progdir/build-system/internals/makier.ksh"

# Immediatly source and run the platform
# checks before doing anything else.
_make 'checks/platform'

. "$progdir/build-system/internals/posix-alt.shi"
. "$progdir/build-system/internals/log.shi"
. "$progdir/build-system/internals/helpers.shi"
. "$progdir/build-system/internals/rconfig.shi"
. "$progdir/build-system/internals/disks.shi"

rconfig "$progdir/build-system/machine.ini"
rconfig "$progdir/build-system/work.ini"
rconfig "$progdir/build-system/fhs.ini"

trash="$(mktemp -d "$TRASH_PREFIX/CopaBuild.XXXXXX")"
map dtime initial "$(date +'%Hh%Mmin on %B %d, %Y')" 
check_for_colour_support
check_elevate_method

_make 'checks/dependencies'
_make 'disk/create_disk' "$DISK_BLOCK"
_make 'disk/populate'
_make get_sources sources.txt sources.sha256
_make build_set cross-tools
_make build_set base
_make finish
