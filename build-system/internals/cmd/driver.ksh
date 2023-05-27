#!/bin/ksh
# Driver for running Copacabana package build recipes.
# Note: This script isn't meant to be run standalone, since it makes use of
# variables exported from the main script, build.ksh
set -x

set -e

# shellcheck disable=SC2068

driver_name="$0"
alambiko_directory="$progdir/packages"
patch_directory="$progdir/patches"

function main {
  if (( $# == 0  )); then
	  print_help
  fi
  while getopts ":D:i" options; do
    case "$options" in
      i) info_flag='true' ;;
      D) typeset -x VARIANT="${OPTARG:-base}" ;;
      *|h) print_help "$OPTARG" ;;
    esac
  done
  shift $(( OPTIND - 1 ))
 
  [ $info_flag ] \
    && print_pkgbuild_info "$1"

  transmutacio "$1"
}

# Transmute from source code to binaries
function transmutacio {
	set -x
	package="$1"
	
	read_pkgbuild "$package"
	
	pushd "$SRCDIR"
		unarchive
	popd

	[ $(defined prepare) ] \
		&& prepare
	
#	[ $(defined patches[@]) ] \
#	&& {
#		for (( i=0; i < $(n ${patches[@]}); i++ )); do
#			printf 'Adding patch no. %s, %s\n' \
#				$(( i + 1 )) "${patches[$i]}"
#			patch_add "${patches[$i]}"
#		done
#	}

	[ $(defined post_install) ] \
		&& {
		pushd "$Destdir"
			post_install
		popd
	}
}

function get_pkgbuild_info {
	package_name="$(echo "$1" | cut -d/ -f2)"
	category="$(echo "$1" | cut -d/ -f1)"

	printf "pkgbuild_dir=%s/%s/%s\n" "$alambiko_directory" \
		"$category" "$package_name"
	# This will read package information from the pkgbuild header, which is
	# defined until it reachs a function declaration
	nawk '/.\(\)/{ exit } 1' \
		"$alambiko_directory/$category/$package_name/pkgbuild"
}
 
function get_pkgbuild_functions {
	package_name="$(echo "$1" | cut -d/ -f2)"
	category="$(echo "$1" | cut -d/ -f1)"
	
	# This will read the pkgbuild functions until the end of the file.
	nawk '/.\(\)/, !/./' \
		"$alambiko_directory/$category/$package_name/pkgbuild"
}

function read_pkgbuild {
	package="$1"
	# Treat the output from get_package_info() to remove white lines and
	# comments, also eval the variables in the script.
	rconfig <(get_pkgbuild_info "$package")

	# Source all the functions defined
	. <(get_pkgbuild_functions "$package")
}

function print_pkgbuild_info {
	get_pkgbuild_info "$1" | sed '/#/d; /^$/d' \
	| while IFS='=' read identifier value; do
		printf '%s:%10s\n' "$identifier" "$value"
	done
	exit
}

function print_help {
  printerr '%s: illegal option "%s"
The following options are used for debugging:
  -i: Print pkgbuild information.
The following options are meant for defining custom build options:
  -D: Define the pkgbuild '\''VARIANT'\'' internal variable.\n' \
    "$driver_name" "$1"
  exit 1
}

main $@
