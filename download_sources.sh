#!/bin/bash
# Simple shell hack to download and MD5 check source tarballs.
# Copyright 2021: Luiz Antônio (takusuman).
# This particular script is dual-licensed between BSD 2-Clause
# or GPL3, at your preference.
# n() function taken from otto-pkg's posix-alt.shi lib.
# Forked from CMLFS.

# USAGE: ./download_sources.sh sources.list sources.md5

MD5CHECK=${MD5CHECK:-YES}
COPA=${COPA:-/dsk/0v}
SRCDIR=${SRCDIR:-$COPA/usr/src}

# Workaround to the # macro in arrays
# which doesn't work properly in bash 4.3 for some reason.
n(){
	echo ${@} | tr " " "\n" | wc -l
}

main(){
	test ! -e $SRCDIR && mkdir -pv $SRCDIR
	PARENTDIR=${PWD}
	categories=(`grep '#>' ${1} | tr -d '#> '`)
	n_categories=`n ${categories[*]}`

	for (( i=0; i < $n_categories; i++ )){
			   # foo/var => foo\/var
		category_id=`echo ${categories[${i}]} | sed 's/\//\\\//g'`
		     	   # Matches #> $category_id | counts until the next and
			   # last match | matches #< $category_id | it ends here           "Translate" \n for spaces
		urls=(`awk "/^#> $category_id$/{flag=1;next}/^#< $category_id$/{flag=0}flag" ${PARENTDIR}/${1} | tr "\n" " "`)
		n_urls=`n ${urls[*]}`
		
		SRCDIR+="/${categories[${i}]}"
		test ! -e $SRCDIR && mkdir -pv $SRCDIR
		cd $SRCDIR
		
		for (( j=0; j < ${n_urls}; j++ )){
			printf '%s\n' "Downloading $(basename ${urls[${j}]})"
			curl -L ${urls[${j}]} -O
		}
		SRCDIR=`echo $SRCDIR | sed "/\/${categories[${i}]}/d"`
	}
	[ ${MD5CHECK} == 'YES' ] &&
	md5sum -c ${PARENTDIR}/${2}
	cd ${PARENTDIR}
	return 0
}

main "${1}" "${2}"
