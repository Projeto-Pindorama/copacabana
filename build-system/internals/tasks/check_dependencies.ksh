function check_dependencies {
	
	ksh_sanity_test="$trash/XXXXXX.sanity.ksh"
	c_sanity_test="$trash/XXXXXX.sanity.c"
	cxx_sanity_test="$trash/XXXXXX.sanity.cxx"
	archiver_sanity="$trash/archiver_sanity"

	# Internal helper scripts (at cmd/)
	internal_scripts=( 'cmd/download_sources.bash' \
		'cmd/populate_fhs.ksh' 'cmd/snapshot_stage.ksh' )

	# General commands
	general_commands=( 'cmp' 'curl' diff{,3} 'sdiff' 'patch' \
		'find' 'grep' 'm4' 'mitzune' )

	# General compressing tools
	archivers=('tar' 'bzip2' 'gzip' 'xz')

	# GNU Binutils commands
	GNUBinutils_commands=( 'addr2line' 'ar' 'as' 'c++filt' 'dwp' 'elfedit' \
		'gprof' ld{,.bfd} 'nm' 'objcopy' 'objdump' 'ranlib' 'readelf' \
		'size' 'strings' 'strip' )

	# GNU auto*conf commands
	GNUAutoconf_commands=( 'aclocal' 'automake' 'autoconf' 'autoscan' \
		'autoreconf' 'ifnames' 'autoheader' 'autom4te' 'autoupdate' \
		'libtool' 'libtoolize' )


	for (( g=0; g < $(n ${general_commands[@]}); g++ )); do
		printerr 'Searching for %s at PATH (%s)... ' \
			"${general_commands[$g]}" "$PATH"
		type -p "${general_commands[$g]}" \
			|| { printerr 'Not found.\n'; return 1; } 
	done

	for (( h=0; h < $(n ${archivers[@]}); h++ )); do
		printerr 'Does %s work for what we want? ' "${archivers[$h]}"
		{
		if [ "${archivers[$h]}" == 'tar'  ]; then # TAR-specific tests
			if [[ "$(readlink -f "$(type -p tar)")" =~ (star) ]] \
				|| $(tar -h 2>&1| grep 'star' 2>&1 >/dev/null); then
				printerr '\nI'\''m almost certain that %s is Schily tar...\n' \
					"$(type -p tar)"
				printerr \
				'I'\''ll disable the secure symbolic links function, for avoiding problems later.\n'
				function tar { "$(readlink -f "$(type -p tar)")" --no-secure-links $@ ;}
				typeset -xf tar
			fi

			{
			( mkdir -p "$archiver_sanity"{,_results}
			cd "$archiver_sanity"
			> vulgar_file
			mkfifo pipe_test
			ln -s "$(readlink -f "$tar_sanity")" potentially_unsafe_link 
			ln -f vulgar_file hard_link
			# We already expect an error/warning
			ln -f not_a_vulgar_file broken_link 2>/dev/null
			)
			( cd "$tar_sanity"
			tar -cf - . ) | tar -xf - -C "${tar_sanity}_results"
			} && rm -rf "${tar_sanity}_results"
		else # Bzip2, Gzip or Xz tests
			for (( l=0; l =< 9; l++ )); do
			        if (( l < 1 )) && [[ "${archivers[$h]}" == 'xz' ]]; then
					l="$(( l + 1 ))"
				fi
				
				printerr '\rWith compression level %s? ' $l
				"${archivers[$h]}" -"$l" -cf | "${archivers[$h]}" -dcf | 
				sleep 0.5
			done
		fi
		} \
		&& printerr 'Sounds like a yes.\n' 
	done
	
#	for (( i=0; i < $(n ${GNUAutoconf_commands[@]}); i++ )); do
#	
#	done
#
#	for (( j=0; j < $(n ${GNUBinutils_commands[@]}); j++ )); do
#
#	done
	
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

cat > "$c_sanity_test" << 'EO_CSANITY'
#include <stdio.h>

#if defined(__GNUC__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
	if (! RETURN) {
		puts("Great, we're on a supported compiler (GCC or LLVM).");
	} else {
		puts("Not on a supported compiler.");
	}
	return RETURN;
}
EO_CSANITY

cat > "$cxx_sanity_test" << 'EO_C++SANITY'
#include <iostream>

#if defined(__GNUG__) || defined(__clang__)
#define RETURN 0
#else
#define RETURN 1
#endif

int main(void) {
	if (! RETURN) {
		std::cout << "Great! We're on a supported compiler (GCC or LLVM)." << std::endl;
	} else {
		std::cout << "Not on a supported compiler." << std::endl;
	}
	return RETURN;
}
EO_C++SANITY

eval "$CC" -o"$trash/c_sanity" "$c_sanity_test"; "$trash/c_sanity"

eval "$CXX" -o"$trash/cxx_sanity" "$cxx_sanity_test"; "$trash/cxx_sanity"
}
