function create_disk {
	disk_block="$1"
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

		if (( disk_size < (virtuadisk_size * 1024) )); then 
			printerr \
			'Warning: %s is smaller (%d MB) than the recommended capacity for building Copacabana (%d MB).\n' \
			"$disk_block" "$disk_size" $(( virtuadisk_size * 1024 ))
		fi
	elif [[ "$VIRTUAL_DISK" ]]; then
		virtuadisk_path="$(realpath "$disk_block")"
		printerr 'Info: Using a virtual disk, located at %s, with a pre-determined size of %d MB.\n' \
			"$virtuadisk_path" $(( virtuadisk_size * 1024 ))

		if [[ ! -e "$virtuadisk_path" ]]; then
			printerr 'Info: Inexistent disk image, creating it...\n'
		elif [[ -e "$virtuadisk_path" && ! -b "$virtuadisk_path" ]]; then
			printerr 'Info: A disk image already exists at %s, do you wish to clean it up and start over?\n' \
				"$virtuadisk_path"
			PS3='Start over? '
			select option in yes no; do
				if [[ "$option" == yes ]]; then
					break
				else
					return 1
				fi
			done
		fi

		printerr 'Info: Creating a virtual disk image at %s, with size of %d MB.\n' \
			"$virtuadisk_path" $(( virtuadisk_size * 1024 ))

		# 1 GB is equal to 2.097.152 blocks.
		# In other words, use:
		# X GB = X * [(1024^2) * 2] blocks
		virtuadisk_blksize="$(( virtuadisk_size * ((1024 ** 2) * 2) ))"
		dd if=/dev/zero of="$virtuadisk_path" bs=512 count=$virtuadisk_blksize

		# Does the size in blocks matches with what du(1)'s getting?
		virtuadisk_reported_size=$(du -s "$virtuadisk_path" | nawk '{print $1}')
		
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
		loop_disk_block="$(elevate losetup --show -P -f "$virtuadisk_path")"

		# That's why we hardcoded the partition to be the first.
		unset disk_block; export disk_block="${loop_disk_block}p1"
	fi
	# Formats the disk block as Ext4 and label it as our defined disk label.
	elevate "$run_shell" -c "mkfs -V -t ext4 '$disk_block' && e2label '$disk_block' '$disk_label'"
	
	# We expect the "dsk" type to be the first in the array on L.E.mount, as
	# in the default /etc/leconf, so we'll be using "1" as the second
	# argument.
	printf '%s\n' "$disk_block" 1 | eval $(elevate lemount)

	# And here we go
	# Making it read-only only to be sure that it won't be getting
	# overwritten by a "non-build.ksh aware" script later.
	export readonly COPA="$ledisk"

	printerr 'Info: Copacabana disk %s mounted at %s.\n' "$disk_block" "$COPA"
}

function populate { 
	# Self-explanatory, just create the directories for the initial
	# toolchain and intermediary chroot toolchain.
	printerr 'Info: Making directories in %s for the building toolchains.\n' \
		"$COPA"
	elevate mkdir "$COPA/"{cross-,}tools
	(cd "$COPA"; ls -lah .)

	# Make a symbolic link from $COPA/cross-tools to /cross-tools, the same
	# for /tools.
	# For instance:
	# {"$COPA/",/}cross-tools expands to $COPA/cross-tools /cross-tools,
	# which is the input that we'd need to ln(1).
	if [[ -d "$COPA/cross-tools" && -d "$COPA/tools" ]]; then
		printerr 'Info: Symbolic linking %s to %s...\n' \
			{"$COPA/",/}cross-tools {"$COPA/",/}tools 
		elevate ln -s {"$COPA/",/}cross-tools
		elevate ln -s {"$COPA/",/}tools
		(cd /; ls -l ./{cross-,}tools)
	fi
	printerr 'Info: Making directories in %s for populating the file system.\n' \
		"$COPA"
	(cd "$COPA"; elevate $run_shell "$progdir/cmd/populate_fhs.ksh")

	printerr 'Info: Making %s, %s and %s writable by the current user.\n' \
		$(realpaths /{cross-,}tools) "$COPA/usr/src"
	elevate chown -RH "$user" /{cross-,}tools "$COPA/usr/src"
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
