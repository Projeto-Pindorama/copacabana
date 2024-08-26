# vim: set filetype=sh :
# Boilerplate for running tasks.
#
# Copyright (c) 2023-2024 Pindorama
# 			  Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA

_make(){
	set -e
	lang='.ksh'
	tasks="${tasks:?"task directory not defined"}"
	made="$tasks/made.txt"
	tak="$1"

	# Since having access to the date of the last
	# change done to a file in the UNIX format is
	# hard without stat(1) or even strace(1)ng the
	# ls(1) program, we will use a rudimentary
	# technique to keep track of tasks that had
	# already being ran.
	if grep -v "$tak" "$made"; then
		shift # Remove '$1'
		. "$(printf '%s/%s%s' "$tasks" "$tak" "$lang")" "${@:-''}"
		# Write task name to a list of done tasks.
		echo $tak >> "$tasks/made.txt"
	fi
}
