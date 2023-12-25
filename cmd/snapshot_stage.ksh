#!/usr/bin/env ksh93
# Simple shell hack to snapshot a Copacabana stage. 
# Copyright 2022-2024: Luiz Antônio (takusuman).
# This script is licensed under UUIC/NCSA (as Copacabana work itself).
# PS: It can also be run in GNU Broken... eh, I mean BOURNE-Again Shell
# if you don't have AT&T's ksh93 installed. 

program=$0
COPA=${COPA:-/dsk/0v}

function main {
	options=':S:d:h'
	while getopts "$options" OPT; do
		case $OPT in
			S) stage=$OPTARG ;;
			d) directory="$OPTARG" ;;
			:|*|?|h) print_help $OPT ;;
		esac
	done
	## May I have to handle this manually
	## Seriously?
	if [ -z $stage ] || [ -z "$directory" ]; then
		print_help $OPT
	fi
	snapshot $stage "$directory"
}

function snapshot {
	stage=$1
	directory="$(realpath "$2")"
	filename="${stage}_$(date +%Y-%m-%d_%H-%M-%S)"
	# This is meant to be used with our Copacabana stages
	# In other words, we will always be looking for stages on $COPA, not
	# elsewhere
       	# Of course, you can change this with some Shell hacking	
	case $stage in
		base) stage_dir="." ;; # This is kind of a shoot in the dark,
					  # since we're considering "." is
					  # $COPA's root just because we cd'd on
					  # it.
		*) stage_dir=$stage ;;
	esac

	printf 'Creating snapshot a snapshot of %s on "%s"\nSaving on %s\n' \
		$stage $filename "$directory"
	sleep 2 \
		&& cd $COPA \
	       && tar -cvf - "$stage_dir" | xz -${XZ_COMPRESSION_LEVEL:-7}e \
	       > "$directory/$filename.tar.xz"	
	return 0
}

function print_help {
	printf '%s: illegal option "%s"\n[usage]: %s -S stage -d /dsk/0/copa_snapshots\n' "$program" "$1" "$program"
	exit 1
}

main $@
