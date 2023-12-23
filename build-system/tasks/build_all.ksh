# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA

# STEP 3: Build
# "Around 3 a.m., the colonel pushed a bunch of papers that were on his front at
# his table. He strected his arms and leaned his head on the cold glass tabletop.
# - 'I need to cool down my head. It looks like it's on fire.'
# Soon after, the red telephone rang. The head of the Agency was calling and he
# wanted to know how the operation was going.
# - 'Yellow Cake already got started, General. So far, so good', Ary responded."
#	-- Alexandre Von Baumgarten's "Yellow Cake"
#
# In this step, there will be the definition of functions to create and format a
# disk, populate it with directories and then, at the end of the build, unmount
# it, respectively.

# And this will be used inside driver.ksh to find where packages/ is.
export progdir trash

# Syntax: build [stage_name] packages ...
function build {
	case $1 in
		cross-tools) shift; build_xtools "$@" ;;
		tools) shift; build_tools "$@" ;;
		base) shift; build_base "$@" ;;
		close) shift; close_build ;;
	esac
}

function build_xtools {
	packages=( "$@" )
	n_packages=$(n "${packages[@]}")
	
	for (( n=0; n < n_packages; n++ )); do
		"$progdir/build-system/internals/cmd/driver.ksh" -Dcross "${packages[$n]}" \
			|| { $I_ENJOY_THAT_THINGS_ARE_REALLY_CLEAR \
			|| printerr 'Error: Failed to build %s, please check log (%s) for more details.\n' \
		       		"${packages[$n]}" "$blackbox"; } 
	done
}

function build_tools {
	return 0
}

function build_base {
	return 0
}

# Note: the titles shall change insofar the script is written.
# STEP 4: Closing the build 
# This function will just write the "/etc/copacabana-release" file on
# the final system, closing the build process.
function close_build {
	version="$progdir/version"
	release_file="$COPA/etc/copacabana-release"
	if [[ ! -s "$version" ]]; then
		printf '%.1f' 0.0 > "$version"
	fi
	map dtime final "$(date +'%Hh%Mmin on %B %d, %Y')"

	printf > "$release_file" \
	'Copacabana %.1f/%s\nCopyright (c) %d-%d Pindorama. All rights reserved.\n\nDesigned between %s and %s. Built from %s until %s (UTC %s).\n' \
		"$(cat $version)" "$CPU" '2019' "$(date +"%Y")" \
		'February 2021' "$(date +'%B %Y')" \
		"${dtime[initial]}" "${dtime[final]}" "$(date +%Z)"
	
	printerr 'Info: Build done at %s.\n' \
		"${dtime[final]}" | tee "$blackbox"

	return 0
}

build "$@"
