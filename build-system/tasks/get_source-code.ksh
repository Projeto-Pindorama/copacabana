function get_sources {
	# Get precise path for both sources.txt and sources.sha256, even though
	# download_sources.ksh already does this internally using a realpath()
	# function.
	source_list="$(readlink -f "$1")"
	source_hash="$(readlink -f "$2")"
	printerr 'Info: Downloading sources for building Copacabana using %s as the list.\n' \
		"$source_list"
	"$progdir/cmd/download_sources.ksh" "$source_list" "$source_hash"
}
