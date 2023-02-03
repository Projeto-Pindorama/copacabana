#!/bin/ksh93
# This script is part of Copacabana's build system.
# Copyright (c) 2023: Pindorama
# C and C++ sanity checks by Samuel (callsamu), Lucas (volatusveritas)
# and Luiz Antônio Rangel (takusuman)
# This script is licenced under UUIC/NCSA (as Copacabana work itself).

set -e
set -x

progname="${0##*/}"
progdir="$(cd "$(dirname "$0")"; pwd -P)"

trash="$(mktemp -d /tmp/CopaBuild.XXXXXX)"

. "$progdir/build-system/internals/helpers.shi"
. "$progdir/build-system/internals/posix-alt.shi"

rconfig $progdir/build-system/machine.conf
rconfig $progdir/build-system/paths.conf

function main {
  check_elevate_method
  check_dependencies
}

function check_dependencies {
  c_sanity_test="$(mktemp "$trash/XXXXXX.sanity.c")"
  cxx_sanity_test="$(mktemp "$trash/XXXXXX.sanity.cxx")"

  # Internal helper scripts (at cmd/)
  internal_scripts=( 'cmd/download_sources.bash' \
    'cmd/populate_fhs.ksh' 'cmd/snapshot_stage.ksh' )

  # General commands
  general_commands=()

  # General compressing tools
  compressors=('bzip2' 'gzip' 'xz')

  # GNU Binutils commands
  GNUBinutils_commands=( 'addr2line' 'ar' 'as' 'c++filt' 'dwp' 'elfedit' \
    'gprof' ld{,.bfd} 'nm' 'objcopy' 'objdump' 'ranlib' 'readelf' 'size' \
    'strings' 'strip' )

  # GNU auto*conf commands
  GNUAutoconf_commands=( 'aclocal' 'automake' 'autoconf' 'autoscan' \
    'autoreconf' 'ifnames' 'autoheader' 'autom4te' 'autoupdate' \
    'libtool' 'libtoolize' )


  for (( g=0; g < $(n ${general_commands[@]}); g++ )); do

  done


  for (( h=0; h < $(n ${compressors[@]}); h++ )); do

  done

  for (( i=0; i < $(n ${GNUAutoconf_commands[@]}); i++ )); do

  done

  for (( j=0; j < $(n ${GNUBinutils_commands[@]}); j++ )); do

  done

  for (( k=0; k < $(n ${internal_scripts[@]}); k++ )); do
    printerr 'Searching for independent script %s at %s... ' \
      "${internal_scripts[$k]}" "$progdir"
    if [ -e "$progdir/${internal_scripts[$k]}" ] \
      && [ ! -z "$(cat "$progdir/${internal_scripts[$k]}")" ]; then
      printerr 'Found!\n'
    else
      printerr '%s not found...\n'
      printerr 'It seems like your Copacabana repository clone is incomplete.\n'
      return 1
    fi
  done

# Programming language interpreters/compilers sanity checks.

cat > "$c_sanity_test" << "EO_CSANITY"
#include <stdio.h>

#if defined(__GNUC__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
        if (! RETURN) {
                puts("Great, we're on a supported compiler (GCC or LLVM).");
        } else {
                puts("Not on a supported compiler.");
        }
        return RETURN;
}
EO_CSANITY

cat > "$cxx_sanity_test" << "EO_C++SANITY"
#include <iostream>

#if defined(__GNUG__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
        if (! RETURN) {
                std::cout << "Great! We're on a supported compiler (GCC or LLVM)." << std::endl;
        } else {
                std::cout << "Not on a supported compiler." << std::endl;
        }
        return RETURN;
}
EO_C++SANITY

eval "$CC -o$trash/c_sanity $c_sanity_test; $trash/c_sanity"

eval "$CXX -o$trash/cxx_sanity $cxx_sanity_test; $trash/cxx_sanity"

}


