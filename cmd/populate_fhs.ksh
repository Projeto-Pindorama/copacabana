#!/usr/bin/env ksh93
# Simple shell hack to populate Copacabana's FHS on a new disk
# Copyright 2022: Luiz Antônio (takusuman).
# This script is licensed under UUIC/NCSA (as Copacabana work itself).
# PS: It can also be run in GNU Broken... eh, I mean BOURNE-Again Shell
# if you don't have AT&T's ksh93 installed.  

COPA=${COPA:-/dsk/0v}
directory_tree=({bin,boot,dev,etc/{,skel},lib,lib64,proc,run,sbin,sys,tmp,usr/{,bin,ccs,etc,include,lib,lib64,sbin,share/{,doc,man,misc},skel,spool,src,tmp},var/{,adm,cache,lib/{,color,misc},log,mail,tmp,run/{,lock},spool/{,mail}}})

function main {
	n_directory_tree=`n ${directory_tree[@]}`
	run_as_root
	check_right_place
	for (( i=0; i < n_directory_tree; i++ )){
	       	printerr 'Creating directory number %s: %s\n' $i "${directory_tree[$i]}"
		mkdir "${directory_tree[$i]}" 2>/dev/null
	}
	exit $?
}

function run_as_root {
	if [ $UID != 0 ]; then
		printerr 'This script must be run using the root user (or doas),
since we'\''ll be changing permissions for some directories later.\n'
		exit 2
	fi
}

function check_right_place {
	# Are we even in the Copacabana directory?
	if [ "`pwd`" != "$COPA" ] || [ -z "$COPA" ]; then
		printerr 'You'\''re not currently chdir'\''d in %s.\n
Although we could chdir you into %s, we'\''re going to cowardly exit the
script.\n' "$COPA" "$COPA"
		exit 1		
	else
		continue
	fi
}

# Workaround to the # macro in arrays
# which doesn't work properly in bash 4.3 for some reason.
# From download_sources.bash
function n {
  # ambiguous redirect? pipe it.
  echo "${@}" | wc -w
}

function printerr {
    printf "$@" 1>&2
}

main
