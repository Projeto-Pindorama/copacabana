# vim: set filetype=sh :
# Boilerplate for running tasks.
#
# Copyright (c) 2023-2024 Pindorama
# 			  Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA

_make() {
	set -e
	lang='.ksh'
	tasks="${tasks:?"task directory not defined"}"
	made="${made:?"task history file not defined.
To disable it, define as the null character device."}"
	tak="$1"

	# Create the file if it does not exist yet.
	[[ ! -e "$made" ]] && echo -n >"$made"

	# Since having access to the date of the last
	# change done to a file in the UNIX format is
	# hard without stat(1) or even strace(1)ng the
	# ls(1) program, we will use a rudimentary
	# technique to keep track of tasks that had
	# already being ran.
	if ! grep "$tak" "$made" >/dev/null; then
		shift # Remove '$1'
		. "$(printf '%s/%s%s' "$tasks" "$tak" "$lang")" "${@:-''}"
		# Write task name to a list of done tasks.
		[[ "$FORGO_TASKS" == *"$tak"* ]] ||
			echo $tak >>"$tasks/made.txt"
	fi
}
