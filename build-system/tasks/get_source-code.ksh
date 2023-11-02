function get_sources {
	# Get precise path for both sources.txt and sources.sha256, even though
	# download_sources.ksh already does this internally using a realpath()
	# function.
	source_list="$(readlink -f "$1")"
	source_hash="$(readlink -f "$2")"
	SRCDIR="$COPA/${SRCDIR_SUFFIX:-/usr/src}"
	SHA256CHECK="$SHA256CHECK"
	export SHA256CHECK SRCDIR

	printerr 'Info: Downloading sources for building Copacabana using %s as the list.\n' \
		"$source_list"

	if ! $USE_ARIA2C; then
		# Get the good ol' download_sources.ksh as our default and
		# secure option since 2021.
		"$progdir/cmd/download_sources.ksh" "$source_list" "$source_hash"
	else
		# A considerable part of this code comes from download_sources.ksh.
		categories=($(grep '#>' "$source_list" | tr -d '#> '))
		n_categories=$(n ${categories[@]})

		for ((c=0; c < n_categories; c++)); do
			# foo/var => foo\/var
			category_id="$(echo ${categories[$c]} | sed 's~\/~\\\/~g')"

			printerr 'Info: Using aria2c instead of cmd/download_sources.ksh...\n'
			printerr 'Info: Downloading %s sources...\n' "${categories[$c]}"

			# sed: Remove comments (lines starting with %%)
			# AWK: Matches #> $category_id | counts until the next and last match | matches #< $category_id | it ends here
			urls=($(sed '/%%/d' "$source_list" \
				| awk "/^#> $category_id$/{flag=1;next}/^#< $category_id$/{flag=0}flag"))
			n_urls=$(n urls)

			category_dir="$SRCDIR/${categories[$c]}"
    			mkdir -p "$category_dir"

			# Hell yeah, speed.
			( for ((u=0; u < $(n ${urls[@]}); u++ )); do 
				printf '%s\n\tout=%s\n' \
				"${urls[$u]}" "${urls[$u]##*/}"
			done ) \
			| aria2c -j $(nproc) -s $(nproc) -d "$category_dir" -i -
			unset category_id category_dir urls n_urls
		done
		if $(printf '%s' "$SHA256CHECK" | grep -i '^y' &>/dev/null); then
			(cd "$SRCDIR"; \
			"$progdir/cmd/sha256sum.ksh" -c "$source_hash")
		fi
		unset categories n_categories
	fi

	unset SHA256CHECK
}
