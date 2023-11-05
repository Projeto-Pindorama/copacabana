# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA

# STEP 2: Ingredients
# "Cr$ 600.000.000? In cash? I can not afford this, General."
#	-- Alexandre Von Baumgarten's "Yellow Cake"
#
# In this step, we'll be getting source code for building the distribution from
# the 'Net. Sounds cool, eh?
# As you can see, we're not calling aria2 or cURL directly, instead we're using
# --- since 2021 --- a script that does it for us.
#
# Some of them are coming from inside --- remember that "eating your own dog
# food" philosophy? So ---, but it's not included inside the Copacabana
# repository for obvious reasons.

function get_sources {
	# Get precise path for both sources.txt and sources.sha256, even though
	# download_sources.ksh already does this internally using a realpath()
	# function.
	source_list="$(readlink -f "$1")"
	source_hash="$(readlink -f "$2")"

	SHA256CHECK="$SHA256CHECK"
	SRCDIR="$SRCDIR"
	USE_ARIA2C="$USE_ARIA2C"
	export USE_ARIA2C SHA256CHECK SRCDIR

	printerr 'Info: Downloading sources for building Copacabana using %s as the list.\n' \
		"$source_list"

	"$progdir/cmd/download_sources.ksh" "$source_list" "$source_hash"

	unset SHA256CHECK USE_ARIA2C
}
