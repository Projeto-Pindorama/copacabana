# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA
# C and C++ sanity checks by Samuel (callsamu), Lucas (volatusveritas)
# and Luiz Antônio Rangel (takusuman)

# STEP 0: Resources, part II
# This file is part of the "step 0" of building Copacabana, it is one of the
# tools that's being used for checking resources on the machine. In this case,
# differently from the platform_checks, it contains a function for checking if
# all the dependencies needed for building Copacabana are present.
# It looks awful, I apologize.

function check_dependencies {
	# The place were sanity tests will be placed
	ksh_sanity_test="$trash/sanity.ksh"
	c_sanity_test="$trash/sanity.c"
	cxx_sanity_test="$trash/sanity.cxx"
	archiver_sanity="$trash/archiver_sanity"

	# Internal helper scripts (at cmd/)
	internal_scripts=( 'cmd/download_sources.ksh' 'cmd/populate_fhs.ksh' \
		'cmd/sha256sum.ksh' 'cmd/snapshot_stage.ksh' )

	# GNU auto*conf commands
	GNUAutoconf_commands=( 'aclocal' 'automake' 'autoconf' 'autoscan' \
		'autoreconf' 'ifnames' 'autoheader' 'autom4te' 'autoupdate' \
		'libtool' 'libtoolize' )

	# GNU Binutils commands
	GNUBinutils_commands=( 'addr2line' 'ar' 'as' 'c++filt' 'dwp' 'elfedit' \
		'gprof' ld{,.bfd} 'nm' 'objcopy' 'objdump' 'ranlib' 'readelf' \
		'size' 'strings' 'strip' )

	# General commands
	general_commands=( 'cmp' 'curl' diff{,3} 'sdiff' 'patch' \
		'find' 'grep' 'm4' 'mitzune' \
		${GNUAutoconf_commands[@]} ${GNUBinutils_commands[@]} )

	# General compressing tools
	archivers=('tar' 'bzip2' 'gzip' 'xz')

	for (( g=0; g < $(n ${general_commands[@]}); g++ )); do
		printerr 'Searching for %s at PATH (%s)... ' \
			"${general_commands[$g]}" "$PATH"
		type -p "${general_commands[$g]}" \
			|| { printerr 'Not found.\n'; return 1; } 
	done

	for (( h=0; h < $(n ${archivers[@]}); h++ )); do
		printerr 'Does %s work for what we want? ' "${archivers[$h]}"
		if [ "${archivers[$h]}" == 'tar'  ]; then # TAR-specific tests
			if [[ "$(readlink -f "$(type -p tar)")" =~ (star) ]] \
				|| $(tar -h 2>&1| grep 'star' 2>&1 >/dev/null); then
				printerr '\nI'\''m almost certain that %s is Schily tar...\n' \
					"$(type -p tar)"
				printerr \
				'I'\''ll disable the secure symbolic links function, for avoiding problems later.\n'
				printerr \
				'Also setting archive type as "xustar" for unlimited file size (grander than 8192 MiB).\n'
				function tar {
					"$(type -p tar)" "$@" \
						--no-secure-links --artype=xustar
				}
				typeset -xf tar
			fi

			{
			( mkdir -p "$archiver_sanity"{,_results}
			cd "$archiver_sanity"
			> vulgar_file
			mkfifo pipe_test
			ln -sf "$(readlink -f "$archiver_sanity")" potentially_unsafe_link 
			ln -f vulgar_file hard_link
			# We already expect an error/warning
			ln -f not_a_vulgar_file broken_link 2>/dev/null
			)
			( cd "$archiver_sanity"
			tar -cf - . ) | tar -xf - -C "${archiver_sanity}_results"
			} && rm -rf "${archiver_sanity}_results"
		else # Bzip2, Gzip or Xz tests
			for (( l=1; l <= 9; l++ )); do
				printerr 'With compression level %s? ' $l
			
				# Test the alphabet string can be compressed
				# without being corrupted, then, do a more
				# "difficult" test using the main build.ksh
				# script file.
				{ printf '%s' {a..z} | "${archivers[$h]}" -"$l" -cf \
					| "${archivers[$h]}" -dcf | wc -m | tr -d '[:space:]' \
					| test `cat` -eq 26 ; } \
				&& { cat "$progdir/$progname" | "${archivers[$h]}" -"$l" -cf \
					| "${archivers[$h]}" -dcf \
				       	| cmp - "$progdir/$progname"; }
					printerr 'Ok...\n'
			done
		fi
		printerr 'Sounds like a yes.\n' 
	done
	
	for (( i=0; i < $(n ${utils[@]}); i++ )); do
		printerr 'Is %s present on this system? ' "${utils[$i]}"
		command -v ${utils[$i]} 2>&1 > /dev/null && printerr 'Sounds like a yes.\n' \
			|| { printerr '%s not found.\n' ${utils[$i]}; return 1; }
	done
	
	for (( k=0; k < $(n ${internal_scripts[@]}); k++ )); do
		printerr 'Searching for independent script %s at %s... ' \
			"${internal_scripts[$k]}" "$progdir"
		if [ -e "$progdir/${internal_scripts[$k]}" ] \
			&& [ ! -z "$(cat "$progdir/${internal_scripts[$k]}")" ]; then
			printerr 'Found!\n'
		else
			printerr '%s not found...\n'
			printerr 'It seems like your Copacabana repository clone is incomplete.\n'
			return 1
		fi
	done

# Programming language interpreters/compilers sanity checks.

run_shell="$(readlink -f /proc/$$/exe)"
printerr 'Does the running shell (%s) work for what we need?\n' "$run_shell"

# Not caching "$(readlink -f /proc/$$/exe)" via $run_shell on the sanity test,
# since we expect it to run as a new process, so as a new P.ID. and as a new
# "folder" at /proc, explaining in a extremely simplistic way.

cat > "$ksh_sanity_test" << 'EO_KSHSANITY'
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
"$run_shell" "$ksh_sanity_test"

printerr 'Does the C/C++ compiler work for what we need?\n' 

cat > "$c_sanity_test" << 'EO_CSANITY'
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

cat > "$cxx_sanity_test" << 'EO_C++SANITY'
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

{ "$CC" -o"$trash/c_sanity" "$c_sanity_test"; "$trash/c_sanity" \
	&& "$CXX" -o"$trash/cxx_sanity" "$cxx_sanity_test" && "$trash/cxx_sanity"; } \
	|| exit $?

printerr 'Info: Generating our cross-compiling host based on this machine'\''s type...\n'
printerr 'Does this system have GNU Broken-Again Shell for $MACHTYPE or we'\''ll be depending on %s? ' \
       	"$CC"
if ! type -p bash 2>&1 > /dev/null; then
	printerr 'Nah, it'\''s clean.\n'
	has_bash=false
else
	printerr 'It does, we'\''re going with it.\n'
	has_bash=true
fi

COPA_HOST="$( ( ($has_bash && bash -c 'echo $MACHTYPE') \
	|| (gcc -v 2>&1 | nawk '/Target/{ sub(/.*Target:/, "", $0); printf("%s", $1); }') ) \
	| nawk '{ split($0, host, "-"); sub(host[2], "crossCOPACABANA", $0); printf("%s\n", $0); }')"
unset has_bash

printerr 'Info: COPA_HOST will be "%s".\n' "$COPA_HOST"

# Exporting our running Shell for using later in other tasks and also the
# $COPA_HOST, that will be used when building the cross-compiler.
export run_shell COPA_HOST

}
