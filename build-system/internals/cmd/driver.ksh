#!/usr/bin/env ksh93
# Driver for running Copacabana package build recipes.
# Note: This script isn't meant to be run standalone, since it makes use of
# variables exported from the main script, build.ksh
set -x

set -e

# shellcheck disable=SC2068

drvname="$1"

# If (and when) ran from build.ksh, this will $0 will be build.ksh, so we can
# get its directory and touché: we also have the base directory for pkgbuilds
# --- since it is intended to be in the same directory as the build system
# itself.
build_kshdir="$(cd "$(dirname "${0##*/}")"; pwd -P)"
progdir="$build_kshdir"
alambiko_directory="$progdir/packages"
patch_directory="$progdir/patches"

# Base directories for building packages, one is for residue, object
# files and source code ("slact"), the other is for built packages ("aqua
# vitæ").
base_objdir="$trash/slact"
base_destdir="$trash/aqua_vitæ"

function main {
	if (( $# == 0 )); then
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

function eval_pkgbuild_path {
	set -x
	package="$1"
	package_name="${package#*/}"
	category="${package%/*}"

	package_recipe="$(find \
		"$alambiko_directory/$category/$package_name" \
		-name 'pkgbuild' -type f -print)" \
		|| { printerr '%s: find failed.\n' "$driver_name"; return 1; }
	printf '%s\n' "$package_recipe"
}

function read_pkgbuild {
	# Treat the output from get_package_info() to remove white lines and
	# comments, also eval the variables in the script.
	rconfig <(get_pkgbuild_info "$package_recipe")

	# Source all the functions defined
	source <(get_pkgbuild_functions "$package_recipe")
}

function print_pkgbuild_info {
	get_pkgbuild_info "$1" | sed '/#/d; /^$/d' \
	| while IFS='=' read identifier value; do
		printf '%s:%10s\n' "$identifier" "$value"
	done
	exit
}

function get_pkgbuild_info {
	package_recipe="$(eval_pkgbuild_path "$1")"

	printf "pkgbuild_dir=%s\n" "$package_recipe"
	# This will read package information from the pkgbuild header, which is
	# defined until it reachs a function declaration
	nawk '/.\(\)/{ exit } 1' "$package_recipe"
}
 
function get_pkgbuild_functions {
	package_recipe="$(eval_pkgbuild_path "$1")"

	# This will read the pkgbuild functions until the end of the file.
	nawk '/.\(\)/, !/./' "$package_recipe"
}

function transmutacio {
	set -x
	package="$1"
	
	read_pkgbuild "$package"

	# Where will files be extracted, this folder may ocupy a lot of space
	# depending on the packages built.
	OBJDIR="$base_objdir/$VARIANT"

	#
	DESTDIR="$base_destdir/$VARIANT/${Archive_name%.t*}"
	export OBJDIR DESTDIR
	
	# Check if every "standard" pkgbuild function is defined before running,
	# so we won't have problems with future "boilerplate" pkgbuilds that
	# just create symbolic links, for instance.
	if $(defined unarchive); then
		# Find the source code archive inside the $SRCDIR using find(1)
		# so we won't be having to alias categories from Alambiko with
		# internal Copacabana category names.
		source_archive_dir="$(dirname "$(find "$SRCDIR" -name "$Archive_name" -type f -print)")"

		pushd "$source_archive_dir"
			unarchive
		popd
	fi

	if $(defined package_conf); then
		# If $Destdir not defined from the pkgbuild, default it
		# to $DESTDIR. It is expected to be declared when the package
		# needs to be installed in a custom location.
		# For instance, cross-tools' and tools' base/LibC package.
		pushd "${Destdir:-$DESTDIR}"
			package_conf
		popd
	fi
}

function print_help {
  printerr '%s: illegal option "%s"
The following options are used for debugging:
  -i: Print pkgbuild information.
The following options are meant for defining custom build options:
  -D: Define the pkgbuild '\''VARIANT'\'' internal variable.\n' \
    "$drvname" "$1"
  exit 1
}

main $@
