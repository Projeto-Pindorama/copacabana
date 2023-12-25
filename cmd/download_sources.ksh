#!/usr/bin/env ksh93 
# Simple shell hack to download and SHA256 check source tarballs.
#
# Copyright 2021 - 2024 Luiz Antônio Rangel (takusuman).
# n() function by Caio Novais (caionova).
# This script is licensed under UUIC/NCSA (as Copacabana work itself).
# Forked from CMLFS, which was originally dual-licensed between
# BSD 2-Clause or GPL3, at your preference.

# USAGE: ./download_sources.sh sources.list sources.sha256

# Word splitting is required.
# shellcheck disable=SC2001,SC2006,SC2086,SC2207

# We expect sha256sum.ksh to be in the same directory as
# download_sources.ksh if running from build.ksh

SHA256CHECK=${SHA256CHECK:-YES}
USE_ARIA2C=${USE_ARIA2C:-false}
COPA=${COPA:-/dsk/0v}
SRCDIR=${SRCDIR:-$COPA/usr/src}
umask 0022

# If we're running from the Copacabana build system, use
# internal sha256sum(1) implementation.
if $BUILD_KSH; then
  build_kshdir="$(cd "$(dirname "${0##*/}")"; pwd -P)"
  sha256sum() { "$build_kshdir/cmd/sha256sum.ksh" "$@"; }
fi

# Workaround to the # macro in arrays
# which doesn't work properly in bash 4.3 for some reason.
n() {
  # ambiguous redirect? pipe it.
  echo "${@}" | wc -w
}

realpath(){
  file_basename=`basename $1`
  file_dirname=`dirname $1`
	# get the absolute directory name
	# example: ./sources.txt -> /usr/src/copacabana-repo/sources.txt
  echo "`cd "${file_dirname}"; pwd`/${file_basename}"
}

# Drop-in replacement to GNU nproc.
nproc(){
  case "`uname -s`" in
    Darwin | Linux) getconf '_NPROCESSORS_ONLN';;
    FreeBSD | OpenBSD | NetBSD) getconf 'NPROCESSORS_ONLN';;
    SunOS) echo "`ksh93 -c 'getconf NPROCESSORS_ONLN'`" ;;
    *) echo 1 ;;
  esac
}

main() {
  sources_file="`realpath ${1}`"
  sources_directory="`realpath ${SRCDIR}`"
  test -n "${2}" && hashsum_file="`realpath ${2}`"
  mkdir -p "$sources_directory"
  categories=(`grep '#>' ${sources_file} | tr -d '#> '`)
  n_categories="`n ${categories[*]}`"

  for ((i = 0; i < n_categories; i++)) {

    # foo/var => foo\/var
    category_id="`echo ${categories[${i}]} | sed 's~\/~\\\/~g'`"
    printf '==> %s\n' "${categories[${i}]}"
    # sed: Remove comments (lines starting with %%)
    # AWK: Matches #> $category_id | counts until the next and last match | matches #< $category_id | it ends here
    urls=(`sed '/%%/d' ${sources_file} | awk "/^#> $category_id$/{flag=1;next}/^#< $category_id$/{flag=0}flag"`)
    n_urls="`n ${urls[*]}`"

    category_dir="$sources_directory/${categories[${i}]}"
    mkdir -p "${category_dir}"

    # cURL is slower, but it's present on more systems per default than aria2c,
    # so we're going with it.
    if ! $USE_ARIA2C; then
	cd "${category_dir}" || exit 2
        for ((j = 0; j < n_urls; j++)) {
          printf 'Downloading %s\n' "`basename ${urls[${j}]}`"  
          curl -LO "${urls[${j}]}" 
        }
    else
        # Hell yeah, speed.
        ( for ((k = 0; k < n_urls; k++)){ 
            printf '%s\n\tout=%s\n' \
                "${urls[$k]}" "${urls[$k]##*/}"
	} ) \
        | aria2c -q -j `nproc` -x `nproc` -d "$category_dir" -i -
    fi
  }
  if `echo ${SHA256CHECK} | grep -i '^y' &>/dev/null` \
	  && `test -n "${hashsum_file}"`; then
      cd "${sources_directory}"
      sha256sum -c "${hashsum_file}" \
	      && cd "${OLDPWD}"
  fi
}

main "$@"
