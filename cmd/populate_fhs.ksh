#!/usr/bin/env ksh93
# Simple shell hack to populate Copacabana's FHS on a new disk
# Copyright 2022: Luiz Antônio (takusuman).
# This script is licensed under UUIC/NCSA (as Copacabana work itself)
# PS: It can also be run in GNU Broken... eh, I mean BOURNE-Again Shell
# if you don't have AT&T's ksh93 installed.  

COPA=${COPA:-/dsk/0v}
directory_tree=({bin,boot,dev,etc,lib,proc,sbin,sys,tmp,usr/{,bin,ccs,etc,include,lib,sbin,share/{,doc,man,misc},skel,spool/{,mail},src,tmp},var/{,adm,cache,lib/{,color,misc},run/{,lock}}})

function main {
	n_directory_tree=`n ${directory_tree[@]}`
	run_as_root
	check_right_place
	for (( i=0; i < n_directory_tree; i++ )){
	       	printerr 'Creating directory number %s: %s\n' $i "${directory_tree[$i]}"
		mkdir "${directory_tree[$i]}" 2>/dev/null
	}

	# This part is a dumpster fire
	# Symbolic links already sucks, and this quick-fix makes it worse
	# Possibly there's a way to make this better, but I'm won't be
	# overthinking it for now.
	printerr 'Linking directories\n'
	# /var
	cd /var
	ln -sv ../usr/tmp/ ./tmp
	ln -sv ../usr/spool/ ./spool
	ln -sv ../usr/spool/mail/ ./mail
	ln -sv ./run/lock/ ./lock
	ln -sv ./adm/ ./log/
	cd $COPA
	# /etc
	cd /etc
	ln -sv ../usr/skel/ ./skel
	cd $COPA
	# /usr (64-bit)
	ln -sv ./lib ./lib64
	cd $COPA
	
	exit $?
}

function run_as_root {
	if [ $UID != 0 ]; then
		printerr 'This script must be ran using the root user (or doas),
since we'\''ll be changing permissions for some directories later.'
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
