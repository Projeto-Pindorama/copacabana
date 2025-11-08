: forgo
# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023-2024: Pindorama
# SPDX-Licence-Identifier: NCSA

# STEP 3: Build
# "Around 3 a.m., the colonel pushed a bunch of papers that were on his front at
# his table. He strected his arms and leaned his head on the cold glass tabletop.
# - 'I need to cool my head down. I have a sensation that it's on fire.'
# Soon after, the red telephone rang. The head of the Agency was calling, and he
# wanted to know how the operation was proceeding.
# - 'Yellow Cake already got started, General. So far, so good', Ary responded."
#	-- Alexandre Von Baumgarten's "Yellow Cake"
#
# In this step, there will be the definition of functions to create and format a
# disk, populate it with directories and then, at the end of the build, unmount
# it, respectively.

set="$1"
shift

case $set in
	toolchain)
		PATH="$(add_to_PATH /cgnutools/bin)"
		Destdir_suffix=cgnutools \
			_build_packages cross/mussel cross/kernel-headers-st1
		Destdir_suffix=llvmtools \
			_build_packages cross/LibC-musl cross/zlib cross/libatomic
		Destdir_suffix=cgnutools \
			_build_packages cross/libunwind cross/LLVM-st1
		Destdir_suffix=llvmtools \
			_build_packages cross/LLVM-st2
		PATH="$(remove_from_PATH /cgnutools/bin)"
		PATH="$(add_to_PATH /llvmtools/bin)"
		Destdir_suffix=llvmtools _build_packages cross/kernel-headers-st2 \
			cross/byacc cross/flex cross/NBSDcurses cross/ksh-93 \
			cross/bzip2 cross/pigz cross/xz-utils cross/GNUgettext \
			cross/heirloom-toolchest cross/GNUm4 cross/GNUmake \
			cross/LibC-compat cross/patch cross/libarchive \
			cross/s-tar cross/GNUsed
		;;
	base) ;;
	close)
		# STEP 4: Closing the build
		# This function will just write the "/etc/copacabana-release"
		# file on the final system, closing the build process.
		version="$progdir/version"
		release_file="$COPA/etc/copacabana-release"
		if [[ ! -s $version ]]; then
			printf '%.1f' 0.0 >"$version"
		fi
		map dtime final "$(date +'%Hh%Mmin on %B %d, %Y')"

		printf >"$release_file" \
			'Copacabana %.1f/%s\nCopyright (c) %d-%d Pindorama. All rights reserved.\n\nDesigned between %s and %s. Built from %s until %s (UTC %s).\n' \
			"$(cat $version)" "$CPU" '2019' "$(date +"%Y")" \
			'February 2021' "$(date +'%B %Y')" \
			"${dtime[initial]}" "${dtime[final]}" "$(date +%Z)"

		log WARN 'Build done at %s.\n' \
			"${dtime[final]}" | tee "$blackbox"
		;;
esac
