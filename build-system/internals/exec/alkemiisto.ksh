#!/bin/ksh
# Driver for running Alambiko package build recipes.
# Note: This script isn't meant to be run standalone, since it makes use of
# variables exported from the main script, build.ksh
set -x

# shellcheck disable=SC2068

driver_name="$0"
alambiko_directory="$progdir/packages"
patch_directory="$progdir/patches"

function main {
  while getopts ":D:" options; do
    case "$options" in
      D) export VARIANT="$OPTARG" ;;
      *|h) print_help "$OPTARG" ;;
    esac
  done
  shift $(( OPTIND -1 ))
  transmutacio "$1"
}

# Transmute from source code to binaries
function transmutacio {
set -x
  package_name="$(echo "$1" | cut -d/ -f2)"
  category="$(echo "$1" | cut -d/ -f1)"
  pkgbuild_location="$alambiko_directory/$category/$package_name"
  [ ! -e "$pkgbuild_location" ] \
    && { printerr '%s: Couldn'\''t open %s: directory not found.\n' \
    "$driver_name" "$pkgbuild_location"; return 1; }
  [ ! -e "$pkgbuild_location/pkgbuild" ] \
    && { printerr '%s: Couldn'\''t open %s: file not found.\n' \
    "$driver_name" "$pkgbuild_location"; return 1; }
  source "$pkgbuild_location/pkgbuild"

  pushd $SRCDIR
  unarchive
  popd

  [ ! -z "${patches[@]}" ] && patch_add ${patches[@]}

  pushd Destdir
  post_install
  popd
}

function print_help {
  printerr '%s: illegal option "%s"
The following options are meant for defining custom build options:
  -D: Define the pkgbuild '\''VARIANT'\'' internal variable.\n' \
    "$driver_name" "$1"
  exit 1
}

main $@
