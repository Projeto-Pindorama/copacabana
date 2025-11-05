# vim: set filetype=sh :
# Boilerplate for running tasks.
#
# Copyright (c) 2023-2025 Pindorama
# 			  Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA
#
# 'mpatch' borrowed and adapted from firasuke's mussel.
# As per its copyright header:
# Copyright (c) 2020-2025, Firas Khalil Khana
#
# SPDX-Licence-Identifier: ISC
#

_make() {
	funcname=$0
	lang='.ksh'
	tasks="${tasks:?"task directory not defined"}"
	made="${made:?"task history file not defined"}"
	tak="$1"

	# This contains tasks that will be re-run even on start-over.
	# Use '|| true' in case of none of the tasks containing the
	# ': forgo' line.
	FORGO_TASKS="$(grep -rl '^: forgo$' "$tasks" || true)"

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
	Destdir_suffix="${nonsetted:-"$Destdir_suffix"}"
	Destdir="${nonsetted:-"$PKGDIR/$package/$Destdir_suffix"}"

	# Backup $Destdir for pkgbuilds that may change it.
	_Destdir="$Destdir"

	# Create $Destdir before running task.
	mkdir -p "$Destdir"

	# Get package information:
	rconfig "$packinfo"
	cd "${nonsetted:-"$SRCDIR/pkgs"}"
	_make "$package/pkgbuild"
	cd -

	cd "${_Destdir%/*}"
	find . -type f -print >pkgproto.txt
	log WARN 'Copying %s contents to %s' "$package" "$COPA"
	# Create directory structure before running cpio.
	find . -type d -exec \
		sh -c 'set -x; shift; if [ ! -L "$COPA/$1" ] \
			&& [ ! -d "$COPA/$1" ] \
			&& [ ! -d "`readlink -f $COPA/$1`" ]; then \
			mkdir -p "$COPA/$1"; fi' {} sh {} \;
	find . ! -type d ! -name 'pkgproto.txt' -depth -print \
		| elevate cpio -vpmu "$COPA"
	cd -

	# Restore global tasks directory location.
	unset tasks
	tasks="$top_tasks"
}

_build_packages() {
	for pack do
		_build_package "$pack"
	done
}

mpatch() {
	level="$1"
	patch_name="$2"
	package_name="$(basename "$(pwd)")"
	log INFO 'Applying patch '\''%s'\'' for %s...\n' \
		$patch_name "$package_name"

	# We're already inside the package directory, so
	# no need for 'cd "$SRCDIR/$2/$2-$3"'.
	patch -p"$level" -i "$PCHDIR/$package_name/${patch_name}.patch" 2>&1
	log INFO "%s patched with %s!\n" "$package_name" "$patch_name"
}
