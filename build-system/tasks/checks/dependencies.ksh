: forgo
# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023-2024: Pindorama
# SPDX-Licence-Identifier: NCSA
# C and C++ sanity checks by Samuel (callsamu), Lucas (volatusveritas)
# and Luiz Antônio Rangel (takusuman)

# STEP 0: Resources, part II
# This file is part of the "step 0" of building Copacabana, it is one of the
# tools that's being used for checking resources on the machine. In this case,
# differently from the platform_checks, it contains a function for checking if
# all the dependencies needed for building Copacabana are present.
# It looks awful, I apologize.

# The place were sanity tests will be placed
ksh_sanity_test="$trash/sanity.ksh"
c_sanity_test="$trash/sanity.c"
cxx_sanity_test="$trash/sanity.cxx"
archiver_sanity="$trash/archiver_sanity"

# Internal helper scripts (at cmd/)
internal_scripts=('cmd/download_sources.ksh' 'cmd/populate_fhs.sh'
	'cmd/sha256sum.ksh' 'cmd/snapshot_stage.ksh')

# GNU auto*hell commands
GNUAutohell_commands=('aclocal' 'automake' 'autoconf' 'autoscan'
	'autoreconf' 'ifnames' 'autoheader' 'autom4te' 'autoupdate'
	'libtool' 'libtoolize')

# GNU Binutils commands
GNUBinutils_commands=('addr2line' 'ar' 'as' 'c++filt' 'dwp' 'elfedit'
	'gprof' ld{,.bfd} 'nm' 'objcopy' 'objdump' 'ranlib' 'readelf'
	'size' 'strings' 'strip')

Devtools_commands=('cmake' 'ninja')

# General commands
general_commands=('apply' 'cmp' 'curl' diff{,3} 'du' 'sdiff' 'ed' \
	'file' 'patch' 'find' 'grep' 'lemount' 'm4' 'mitzune'
	${GNUAutoconf_commands[@]} ${GNUBinutils_commands[@]} \
		${Devtools_commands[@]})

# General compressing tools
archivers=('tar' 'bzip2' 'gzip' 'xz')

# Check for aria2c
if $USE_ARIA2C; then
	general_commands[2]='aria2c'
fi

for ((h = 0; h < $(n ${archivers[@]}); h++)); do
	log INFO 'Does %s work for what we want? ' "${archivers[$h]}"
	if [ "${archivers[$h]}" == 'tar' ]; then # TAR-specific tests
		tarpath="$(realpath $(type -p tar))"
		if (strings "$tarpath" | grep '@(#)tar.*\(gritter\)' &&
			getconf HEIRLOOM_TOOLCHEST_VERSION) 2>&1 >/dev/null; then
			log WARN 'I'\''m almost certain that %s is from the Heirloom Toolchest...' \
				"$tarpath"
			log WARN 'Heirloom Toolchest'\''s tar is broken since at least 2007 for some reason.'
			log WARN \
				'Until this is hopefully fixed, I'\''ll be searching for another tar at PATH.'

			printf '%s' "$PATH" |
				nawk '{ gsub(":", "\n"); print $0; }' |
				for (( ; ; )); do
					if read -r d; then
						tar_cmd="$d/tar"
						if [[ ! -e $tar_cmd || $d == "${tarpath%/*}" ]]; then
							continue
						elif ("$tar_cmd" --help 2>&1 | \
							egrep 'star|bsdtar|GNU|Toybox|BusyBox' 2>&1 >/dev/null); then
							new_tarpath="$(realpath $d)"
							log WARN 'Found suitable tar at %s\n' "$new_tarpath"
							PATH="$(add_to_PATH "$new_tarpath")"
							log INFO 'New $PATH: %s\n' $PATH
							export PATH
							unset tarpath tar_cmd new_tarpath
							break
						fi
						unset tar_cmd
					else
						panic 'Couldn'\''t find a suitable tar implementation.'
						break # Une pure formalité.
					fi
				done
		fi

		if [[ $tarpath =~ (star) ]] ||
			(tar -h 2>&1 | grep 'star' 2>&1 >/dev/null); then
			log INFO 'I'\''m almost certain that %s is Schily tar...' \
				"$(type -p tar)"
			log INFO \
				'I'\''ll disable the secure symbolic links function, for avoiding problems later.'
			function tar {
				"$(type -p tar)" "$@" \
					--no-secure-links
			}
			typeset -xf tar
		fi
		unset tarpath

		{
			(
				mkdir -p "$archiver_sanity"{,_results}
				cd "$archiver_sanity"
				>vulgar_file
				mkfifo pipe_test
				ln -sf "$(readlink -f "$archiver_sanity")" potentially_unsafe_link
				ln -f vulgar_file hard_link
				# We already expect an error/warning
				ln -f not_a_vulgar_file broken_link 2>/dev/null
			)
			(
				cd "$archiver_sanity"
				tar -cf - .
			) | tar -xf - -C "${archiver_sanity}_results"
		} && rm -rf "${archiver_sanity}_results"
	else # Bzip2, Gzip or Xz tests
		for ((l = 1; l <= 9; l++)); do
			log INFO 'With compression level %s? ' $l

			# Test the alphabet string can be compressed
			# without being corrupted, then, do a more
			# "difficult" test using the main build.ksh
			# script file.
			{ printf '%s' {a..z} | "${archivers[$h]}" -"$l" -cf |
				"${archivers[$h]}" -dcf | wc -m | tr -d '[:space:]' |
				test $(cat) -eq 26; } &&
				{ cat "$progdir/$progname" | "${archivers[$h]}" -"$l" -cf |
					"${archivers[$h]}" -dcf |
					cmp - "$progdir/$progname"; }
			log INFO 'Ok...'
		done
	fi
	log INFO 'Sounds like a yes.'
done

# Considering that the code above messes with the PATH variable,
# we should do the test for the GNU dd after it.
for ((g = 0; g < $(n ${general_commands[@]}); g++)); do
	log INFO 'Searching for %s at PATH (%s)... ' \
		"${general_commands[$g]}" "$PATH"
	if ! type -p "${general_commands[$g]}" 2>&1 >/dev/null; then
		case "${general_commands[$g]}" in
			'sha256sum')
				# Use internal sha256sum implementation
				function sha256sum {
					"$build_kshdir/cmd/sha256sum.ksh" "$@"
				}
				typeset -xf sha256sum
				;;
			*)
				log ERROR '%s not found.' "${general_commands[$g]}"
				;;
		esac
	else
		case "${general_commands[$g]}" in
			'du')
				log INFO 'Is %s GNU? ' "$(type -p du)"
				if (du --help 2>&1 |
					egrep 'POSIXLY_CORRECT|GNU' 2>&1 >/dev/null); then
					log INFO 'Right, it is.\n'
					POSIXLY_CORRECT=true
					export POSIXLY_CORRECT
				fi
				;;
			*) continue ;;
		esac
	fi
done

for ((k = 0; k < $(n ${internal_scripts[@]}); k++)); do
	log INFO 'Searching for independent script %s at %s... ' \
		"${internal_scripts[$k]}" "$progdir"
	if [ -x "$progdir/${internal_scripts[$k]}" ]; then
		log INFO 'Found!'
	else
		log WARN '%s not found...' "${internal_scripts[$k]}"
		panic 'It seems like your Copacabana repository clone is incomplete.'
	fi
done

# Programming language interpreters/compilers sanity checks.
run_shell="$(readlink -f /proc/$$/exe)"
log INFO 'Does the running shell (%s) work for what we need?' "$run_shell"

# Not caching "$(readlink -f /proc/$$/exe)" via $run_shell on the sanity test,
# since we expect it to run as a new process, so as a new P.ID. and as a new
# "folder" at /proc, explaining in a extremely simplistic way.
cat >"$ksh_sanity_test" <<'EO_KSHSANITY'
#!/usr/bin/env ksh
interpreter="$(readlink -f /proc/$$/exe)" 	

if [[ "$interpreter" =~ (ksh|ksh93) ]]; then
print -f \
'It seems like %s is Korn Shell 93, but let me test it... ' \
	"$interpreter" 1>&2
if (PATH=.; alias -x) && [ -z $BASH ] && [ -n ${.sh.version} ]; then
	print -f 'Well, it is, time to move on.\n' 1>&1
fi
elif [[ "$interpreter" =~ (bash) && -n $BASH ]]; then
printf 'It seems like %s is GNU Broken-Again Shell.
Anyway, this script is designed to work with it. Move on.\n' \
"$interpreter" 1>&2
else
printf '%s is unsupported. Oddly, it passed the platform checks, but not these small sanity tests.
Please, report this at https://github.com/Projeto-Pindorama/copacabana.\n' "$interpreter"
return 1
fi
EO_KSHSANITY
log PROGOUT "$ksh_sanity_test"
"$run_shell" "$ksh_sanity_test"

log INFO 'Does the C/C++ compiler work for what we need?'

cat >"$c_sanity_test" <<'EO_CSANITY'
#include <stdio.h>

#if defined(__GNUC__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
if (! RETURN) {
	puts("Great! We're on a supported C compiler (GCC or LLVM).");
} else {
	puts("Not on a supported compiler.");
}
return RETURN;
}
EO_CSANITY

cat >"$cxx_sanity_test" <<'EO_C++SANITY'
#include <iostream>
using std::cout;

#if defined(__GNUG__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
if (! RETURN) {
	std::cout << "Great! We're on a supported C++ compiler (GCC or LLVM)." << std::endl;
} else {
	std::cout << "Not on a supported compiler." << std::endl;
}
return RETURN;
}
EO_C++SANITY

log PROGOUT "$CC" "$("$CC" -o"$trash/c_sanity" "$c_sanity_test")\n"
log PROGOUT "$trash/c_sanity" "$($trash/c_sanity)"
log PROGOUT "$CXX" "$("$CXX" -o"$trash/cxx_sanity" "$cxx_sanity_test")\n"
log PROGOUT "$trash/cxx_sanity" "$($trash/cxx_sanity)"
if ! ("$trash/c_sanity" || "$trash/cxx_sanity") 2>&1 >/dev/null; then
	log ERROR 'Error at the C/C++ compiler sanity tests.'
fi

log INFO 'Generating our cross-compiling host based on this machine'\''s type...'
log DEBUG 'Does this system have GNU Broken-Again Shell for $MACHTYPE or we'\''ll be depending on %s?' \
	"$CC"
if ! type -p bash 2>&1 >/dev/null; then
	log DEBUG 'Nah, it'\''s clean.'
	has_bash=false
else
	log DEBUG 'It does, we'\''re going with it.'
	has_bash=true
fi

COPA_HOST="$( ( ($has_bash && bash -c 'echo $MACHTYPE') ||
	(gcc -v 2>&1 | nawk '/Target/{ sub(/.*Target:/, "", $0); printf("%s", $1); }')) |
	nawk '{ split($0, host, "-"); sub(host[2], "crossCOPACABANA", $0); printf("%s\n", $0); }')"
unset has_bash

log INFO 'COPA_HOST will be "%s".' "$COPA_HOST"

# Exporting our running Shell for using later in other tasks and also the
# $COPA_HOST, that will be used when building the cross-compiler.
export run_shell COPA_HOST
