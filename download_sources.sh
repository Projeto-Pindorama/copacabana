#!/bin/bash
# Simple shell hack to download and MD5 check source tarballs.
# Copyright 2021: Luiz Antônio (takusuman).
# This particular script is dual-licensed between BSD 2-Clause
# or GPL3, at your preference.
# n() function by Caio Novais (chexier).
# Forked from CMLFS.

# USAGE: ./download_sources.sh sources.list sources.md5

# Word splitting is required.
# shellcheck disable=SC2006,SC2086,SC2207

MD5CHECK=${MD5CHECK:-YES}
COPA=${COPA:-/dsk/0v}
SRCDIR=${SRCDIR:-$COPA/usr/src}

# Workaround to the # macro in arrays
# which doesn't work properly in bash 4.3 for some reason.
n() {
  wc -w < "${@}"
}

main() {
  mkdir -p "$SRCDIR"
  PARENTDIR="$PWD"
  categories=(`grep '#>' ${1} | tr -d '#> '`)
  n_categories=`n ${categories[*]}`

  for ((i = 0; i < n_categories; i++)) {
    # foo/var => foo\/var
    category_id=`echo ${categories[${i}]} | sed 's/\//\\\//g'` # SED SUCKS
    # Matches #> $category_id | counts until the next and
    # last match | matches #< $category_id | it ends here "Translate" \n for spaces
    urls=(`awk "/^#> $category_id$/{flag=1;next}/^#< $category_id$/{flag=0}flag" ${PARENTDIR}/${1}`)
    n_urls=`n ${urls[*]}`

    SRCDIR+="/${categories[${i}]}"
    mkdir -p "$SRCDIR"
    cd "$SRCDIR" || exit

    for ((j = 0; j < n_urls; j++)) {
      printf '%s\n' "Downloading $(basename ${urls[${j}]})"
      curl -LO ${urls[${j}]}
    }
    SRCDIR=`echo $SRCDIR | sed "/\/${categories[${i}]}/d"`
  }
  if [ ${MD5CHECK} == 'YES' ]; then
    md5sum -c ${PARENTDIR}/${2}
  fi
}

main "${1}" "${2}"
