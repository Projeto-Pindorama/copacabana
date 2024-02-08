# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023-2024: Pindorama
# SPDX-Licence-Identifier: NCSA

# STEP 1: "Pindorama presents: Fubá Cake" 
# In this step, we will create and format a disk, virtual or physical.
function create_disk {
	disk_block="$1"

	# Set first_time flag to indicate that it's the first time building the
	# system.	
	first_time=true
	
	# Estabilish a default size of 20 GB for a virtual disk
	virtuadisk_size=${VIRTUADISK_SIZE:-20}
	disk_label=${DISK_LABEL:-'Copacabana'}

	# These are only used in virtual disks
	# o = Use a DOS label
	# n = Create a new partition
	# p = Primary, of course
	# 1 = The first one in the disk
	# ' ' = No-op
	# t = Use a type
	# 83 = Linux partition type
	# w = Write 'n quit
	fdisk_steps=( 'o' 'n' 'p' '1' ' ' ' ' 't' '83' 'w' )

	if (( ${#disk_label} > 16 )); then
		printerr \
		'Warning: This disk label ("%s") exceeds e2label'\''s VOLNAMSZ (%d) in %d characters.\n' \
			"$disk_label" 16 $(( ${#disk_label} - 16 ))
		printerr \
		'Warning: Falling back to the default value so we does not get any warnings from e2label.\n'
		unset disk_label; disk_label='Copacabana'
	fi

	printerr 'Info: %s only creates a plain disk, without partitions for /boot, /usr, etc.\n' $0
	if [[ ! "$VIRTUAL_DISK" && -b "$disk_block" ]]; then
		# Get the disk size from /proc/partitions, pretty
		# self-explanatory.
		disk_size="$(grep "${disk_block##*/}\$" /proc/partitions \
			| nawk '{ printf "%0.1f\n", ($(NF -1) / 1024); }')"

		printerr 'Info: Using a physical disk, present at %s with size of %d MB.\n' \ 
			"$disk_block" "$disk_size"

		if (( disk_size < (10 * 1024) )); then 
			panic \
			'Disk %s is too small (%d MB). %d MB is the recommended capacity for building Copacabana.\n' \
			"$disk_block" "$disk_size" $(( 10 * 1024 ))
		# Do not accept disks/disk partitions larger than 50GB.
		elif (( disk_size > (50 * 1024) )); then
			panic \
			'Disk %s is too large. Create a partition and/or use a virtual disk smaller than %d MB.\n' \
			"$disk_block" $(( 50 * 1024 ))
		fi
	
		# Check if disk is already initialized.	
		if $(elevate fdisk -x "${disk_block%%?}" | grep "$disk_block" &>/dev/null); then
			filesystem=$(eval $(blkid -o udev "$disk_block");
					printf '%s\n' "$ID_FS_TYPE")

			if ! check_linuxfs $filesystem; then
				panic \
				'%s is not intended for containing a Linux system.\nDid you mean creating a virtual disk image inside %s?\n' \
				$filesystem "$disk_block"
			fi

			# If we have a compatible file system on the disk, we
			# shall already set as not being the first time.
			first_time=false
		fi
	elif [[ "$VIRTUAL_DISK" ]]; then
		virtuadisk_path="$(realpath "$disk_block")"
		printerr 'Info: Using a virtual disk, located at %s, with a pre-determined size of %d MB.\n' \
			"$virtuadisk_path" $(( virtuadisk_size * 1024 ))

		if [[ ! -e "$virtuadisk_path" ]]; then
			printerr 'Info: Inexistent disk image, creating it...\n'
		elif [[ -e "$virtuadisk_path" && ! -b "$virtuadisk_path" ]]; then
			printerr 'Info: A disk image already exists at %s, do you wish to continue or clean it up and start over?\n' \
				"$virtuadisk_path"
			first_time=false
		fi
	fi
	
	if ! $first_time; then
		start_over=false
		PS3='Continue? '
		select option in yes no quit; do
			case "$option" in
				# This will (L.E.)mount the disk and view if
				# there is something that can be done.
				yes) break ;;
				no) start_over=true ;;
				quit|*) return 1 ;;
			esac
		done
	fi

	if "$VIRTUAL_DISK"; then
		if ( $first_time || $start_over ); then
			printerr 'Info: Creating a virtual disk image at %s, with size of %d MB.\n' \
				"$virtuadisk_path" $(( virtuadisk_size * 1024 ))

			# 1 GB is equal to 2.097.152 blocks.
			# In other words, use:
			# X GB = X * [(1024^2) * 2] blocks
			virtuadisk_blksize="$(( virtuadisk_size * ((1024 ** 2) * 2) ))"
			dd if=/dev/zero of="$virtuadisk_path" bs=512 count=$virtuadisk_blksize

			# Does the size in blocks matches with what du(1)'s getting?
			virtuadisk_reported_size=$(du -s "$virtuadisk_path" | nawk '{ printf("%d", $1); }')
		
			if (( virtuadisk_blksize == virtuadisk_reported_size )); then
				printerr 'Info: %s is o.k. Proceeding.\n' "$virtuadisk_path"
			else
			       	printerr 'Error: dd failed to write %d blocks to %s.\n' \
					$virtuadisk_blksize "$virtuadisk_path"
				printerr 'Error: It possible reported an error and/or an interruption signal before this message.\n'
				printerr 'Error: Please, check. Stopping the build process.\n'
				return 1
			fi

			# For some reason, echo won't be working for this, so let be
			# sticking with printf '%s\n'.
			printf '%s\n' "${fdisk_steps[@]}" | elevate fdisk "$virtuadisk_path"
		fi

		# Expose the virtual disk to the system.
		loop_disk_block="$(elevate losetup --show -P -f "$virtuadisk_path")"

		# That's why we hardcoded the partition to be the first.
		unset disk_block; export disk_block="${loop_disk_block}p1"
	fi
	if ( $first_time || $start_over ); then
		# Formats the disk block as Ext4 and label it as our defined disk label.
		elevate "$run_shell" -c "mkfs -V -t ext4 '$disk_block' && e2label '$disk_block' '$disk_label'"
	fi

	# We expect the "dsk" type to be the first in the array on L.E.mount, as
	# in the default /etc/leconf, so we'll be using "1" as the second
	# argument.
	printf '%s\n' "$disk_block" 1 | eval $(elevate lemount)

	# And here we go.
	# Making it read-only only to be sure that it won't be getting
	# overwritten by a "non-build.ksh aware" script later.
	export readonly COPA="$ledisk"

	printerr 'Info: Copacabana disk %s mounted at %s.\n' "$disk_block" "$COPA"
}

# May use this function later, no use for it for now.
function get_size_blocks {
	typeset -a disk_size[2]
	disk_block="$1"

	# The minimum size for a block is 512KiB, not less.
	# This identifier may sound a little bit erred.
	readonly blocks_per_kib=512
	
	disk_size=( $(elevate fdisk -x "$disk_block" \
		| sed '1 s/Disk .*: \(.*\),.*,.*/\1/; 1q') )

	size=${disk_size[0]}
	sizeunit=${disk_size[1]}
	unset disk_size

	case $sizeunit in
		'TiB') ((blocks= size * (blocks_per_kib * 4194304) )) ;;
		'GiB') ((blocks= size * (blocks_per_kib * 4096) )) ;;
		'MiB') ((blocks= size * (blocks_per_kib * 4) )) ;;
		'KiB') ((blocks= size / blocks_per_kib )) ;;
 	esac
	unset size sizeunit

	printf '%d' $blocks

	return 0
}

# STEP 1.5: Populate the file system
# This function will run the cmd/populate_fhs.sh script and create directories
# for the toolchains that will be built. 
function populate { 
	# That's the time to decide which will be, in fact, our source-code directory.
	SRCDIR="$COPA/${SRCDIR_SUFFIX:-/usr/src}"
	# Also declare who will be our log file.
	blackbox="$COPA/build.log.$CPU"

	# Self-explanatory, just create the directories for the initial
	# toolchain and intermediary chroot toolchain.
	printerr 'Info: Making directories in %s for the building toolchains.\n' \
		"$COPA"
	elevate mkdir "$COPA/"{cgnu,llvm}tools
	(cd "$COPA"; ls -lah .)

	# Make a symbolic link from $COPA/cgnutools to /cgnutools, the same
	# for /llvmtools.
	# For instance:
	# {"$COPA/",/}cgnutools expands to $COPA/cgnutools /cgnutools,
	# which is the input that we'd need to ln(1).
	if [[ -d "$COPA/cgnutools" && -d "$COPA/llvmtools" ]]; then
		printerr 'Info: Symbolic linking %s to %s...\n' \
			{"$COPA/",/}cgnutools {"$COPA/",/}llvmtools 

		# If /cgnutools is already a symbolic link to
		# $COPA/cgnutools, then don't re-do it. Else, if it's a
		# symbolic link but it doesn't link to $COPA/cgnutools,
		# re-do it.
		# The same applies to /llvmtools.
		[[ $(realpath /cgnutools) != "$COPA/cgnutools" ]] \
		&& elevate rm /cgnutools
		( test -L /cgnutools \
		&& [[ $(realpath /cgnutools) == "$COPA/cgnutools" ]] ) \
		|| elevate ln -s {"$COPA/",/}cgnutools 

		
		[[ $(realpath /llvmtools) != "$COPA/llvmtools" ]] \
		&& elevate rm /llvmtools
		( test -L /llvmtools \
		&& [[ $(realpath /llvmtools) == "$COPA/llvmtools" ]] ) \
		|| elevate ln -s {"$COPA/",/}llvmtools

		(cd /; ls -l ./{cgnu,llvm}tools)
	fi

	printerr 'Info: Making directories in %s for populating the file system.\n' \
		"$COPA"
	elevate $run_shell -c "COPA=$COPA BUILD_KSH=$BUILD_KSH $progdir/cmd/populate_fhs.sh; mkdir -p "$SRCDIR""

	printerr 'Info: Initializing blackbox file (%s) for the build.\n' \
		"$blackbox"
	( cd "$COPA"; elevate sh -c "> $blackbox; chown $user $blackbox" )

	printerr 'Info: Making %s, %s and %s writable by the current user.\n' \
		$(realpaths /{cgnu,llvm}tools) "$SRCDIR"
	elevate chown -RH "$user" /{cgnu,llvm}tools "$SRCDIR"
	export blackbox SRCDIR
}

function unmount_and_detach {
	# Korn Shell variables, unlike GNU Broken-Again Shell, are scoped to the
	# function without the need to use the "local" keyword, so we mustn't
	# worry about having another variable with the same "disk_block"
	# identifier.
	mount_point="$1"
	disk_block="$2"
	
	elevate "$run_shell" -c \
		"umount -R '"$mount_point"' '"/mnt/`echo "$mount_point" | sed 's@/@@g'`"'"
	if $VIRTUAL_DISK; then
		elevate losetup -D "${disk_block%%*p?}"
	fi
}

# This checks for valid file systems on
# which Copacabana builds are made and
# tested.
function check_linuxfs {
	fs=$1
	err=0

	case $fs in
		btrfs|ext4) break ;;
		default) err=1; break ;;
	esac

	return $err
}
