#!/bin/sh
# Simple shell hack to populate Copacabana's FHS on a new disk
# Copyright (c) 2023-2024 Pindorama
#                    	  Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA

progname="${0##*/}"
COPA=${COPA:-/dsk/0v}
mtab='/etc/mtab'
fhs_spec="$(cd "$(dirname build.ksh)"; pwd -P)/build-system/fhs.ini"
BUILD_KSH=${BUILD_KSH:-false}
F=${F:-$(sed '/.*DIRS=".*"/!d; s/.*DIRS="\(.*\)"/\1/g' "$fhs_spec")}

# Considering that directories were not defined by build.ksh
if ! $BUILD_KSH; then
	{
	printf 1>&2 \
	'%s is not intended to be run outside Copacabana'\''s build system.\n' \
		"$progname"
	exit 2
	}
fi

if [ "$(whoami)" != 'root' ]; then
	# panic
	{
	printf 1>&2 'You must be '\''root'\'' to run %s.\n' "$progname"
	exit 126
	}
fi

# Is the Copacabana build disk mounted?
printf 1>&2 'Checking if %s is a mountpoint...\n' "$COPA"
{
while read line; do
	disk="${line%%[[:space:]]*}"
	dirtotest_=${line#*[[:space:]]}
	dirtotest=${dirtotest_%%[[:space:]]*}
	if [ "x$dirtotest" = "x$COPA" ]; then
		printf 1>&2 'Found %s as a mountpoint for %s.\n' \
			"$COPA" "$disk"
		err=0
		break
	fi
	unset disk dirtotest_ dirtotest
	# Not mounted?
	err=1
done < "$mtab"
}
if [ $err != 0 ]; then
	printf 1>&2 '%s not mounted?\n' \
		"$COPA"
	exit 255
fi

printf 1>&2 'Creating directories in '\''%s'\''.\n' $COPA
(
cd $COPA
eval $(printf 'for folder in %s; do mkdir -m 755 "./$folder"; done; err=$?' "$F")
)

exit $err
