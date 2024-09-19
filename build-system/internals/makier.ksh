# vim: set filetype=sh :
# Boilerplate for running tasks.
#
# Copyright (c) 2023-2024 Pindorama
# 			  Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA

_make() {
	funcname=$0
	lang='.ksh'
	tasks="${tasks:?"task directory not defined"}"
	made="${made:?"task history file not defined"}"
	tak="$1"

	# This contains tasks that will be re-run even on start-over.
	FORGO_TASKS="$(grep -rl '^: forgo$' "$tasks")"

	# Create the file if it does not exist yet.
	[[ ! -e $made ]] && echo -n >"$made"

	# Since having access to the date of the last
	# change done to a file in the UNIX format is
	# hard without stat(1) or even strace(1)ng the
	# ls(1) program, we will use a rudimentary
	# technique to keep track of tasks that had
	# already being ran.
	if ! grep "$tak" "$made" >/dev/null; then
		shift # Remove '$1'
		printf '%s: running task '\''%s'\''\n' \
			$funcname "$tak" 1>&2
		. "$(printf '%s/%s%s' "$tasks" "$tak" "$lang")" "${@:-''}"
		printf '%s: task done\n' \
			"$funcname" 1>&2
		# Write task name to a list of done tasks.
		[[ $FORGO_TASKS == *"$tak"* ]] ||
			echo $tak >>"$made"
	fi
}

_build_package() {
	unset nonsetted
	packagedir="$progdir/packages"
	top_tasks="$tasks"
	unset tasks
	tasks="$packagedir"
	package="$1"
	packinfo="$packagedir/$package/info.ini"
	Destdir="${nonsetted:-"$OBJDIR/$package"}"

	# Get package information:
	rconfig "$packinfo"
	cd "${nonsetted:-"$SRCDIR/pkgs"}"
	_make "$package/pkgbuild"
	cd -

	cd "$Destdir"
	find . -type f -print >pkgproto.txt
	log WARN 'Copying %s contents to %s' "$package" "$COPA"
	tar -cvf - . | tar -xvf - -C "$COPA"
	cd -

	# Restore global tasks directory location.
	unset tasks
	tasks="$top_tasks"
}
