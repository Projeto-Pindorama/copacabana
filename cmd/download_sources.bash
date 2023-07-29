#!/usr/bin/env bash
# Simple shell hack to download and SHA256 check source tarballs.
#
# Copyright 2021 - 2023 Luiz Antônio Rangel (takusuman).
# n() function by Caio Novais (caionova).
# This script is licensed under UUIC/NCSA (as Copacabana work itself).
# Forked from CMLFS, which was originally dual-licensed between
# BSD 2-Clause or GPL3, at your preference.

# USAGE: ./download_sources.sh sources.list sources.sha256

# Word splitting is required.
# shellcheck disable=SC2001,SC2006,SC2086,SC2207

SHA256CHECK=${SHA256CHECK:-YES}
COPA=${COPA:-/dsk/0v}
SRCDIR=${SRCDIR:-$COPA/usr/src}
umask 0022

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
    # (N)awk: Matches #> $category_id | counts until the next and last match | matches #< $category_id | it ends here
    urls=(`sed '/%%/d' ${sources_file} | awk "/^#> $category_id$/{flag=1;next}/^#< $category_id$/{flag=0}flag"`)
    n_urls="`n ${urls[*]}`"

    category_dir="$sources_directory/${categories[${i}]}"
    mkdir -p "${category_dir}"
    cd "${category_dir}" || exit 2

    for ((j = 0; j < n_urls; j++)) {
      printf 'Downloading %s\n' "`basename ${urls[${j}]}`"
      curl -LO "${urls[${j}]}"
    }
  }
  if `echo ${SHA256CHECK} | grep -i '^y' &>/dev/null` \
	  && `test -n "${hashsum_file}"`; then
      cd "${sources_directory}"
      sha256sum -c "${hashsum_file}" \
	      && cd "${OLDPWD}"
  fi
}

main "$@"
