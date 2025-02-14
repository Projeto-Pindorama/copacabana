: forgo
# STEP 1: "Pindorama presents: Fubá Cake"
# In this step, we will create and format a disk, virtual or physical.
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
fdisk_steps=('o' 'n' 'p' '1' ' ' ' ' 't' '83' 'w')

if ((${#disk_label} > 16)); then
	log WARN \
		'This disk label ("%s") exceeds e2label'\''s VOLNAMSZ (%d) in %d characters.' \
		"$disk_label" 16 $((${#disk_label} - 16))
	log WARN \
		'Falling back to the default value so we does not get any warnings from e2label.'
	unset disk_label
	disk_label='Copacabana'
fi

log WARN '%s only creates a plain disk, without partitions for /boot, /usr, etc.' $0
if [[ ! $VIRTUAL_DISK ]] && [[ -b $disk_block ]] ||
	([[ "$(uname -s)" == "Linux" ]] && ((KSH93_RELEASE <= 20211217)) &&
		(grep "${disk_block##*/}" /proc/partitions 2>&1 >/dev/null &&
			[[ "$(file "$disk_block")" =~ (.*[\t ]block special.*) ]])); then
	# Get the disk size from /proc/partitions, pretty
	# self-explanatory.
	disk_size="$(grep "${disk_block##*/}\$" /proc/partitions |
		nawk '{ printf "%0.1f\n", ($(NF -1) / 1024); }')"

	log INFO 'Using a physical disk, present at %s with size of %d MB.' \
		"$disk_block" "$disk_size"

	if ((disk_size < (10 * 1024))); then
		panic \
			'Disk %s is too small (%d MB). %d MB is the recommended capacity for building Copacabana.' \
			"$disk_block" "$disk_size" $((10 * 1024))
	# Do not accept disks/disk partitions larger than 50GB.
	elif ((disk_size > (50 * 1024))); then
		panic \
			'Disk %s is too large. Create a partition and/or use a virtual disk smaller than %d MB.' \
			"$disk_block" $((50 * 1024))
	fi

	# Check if disk is already initialized.
	if $(elevate fdisk -x "${disk_block%%[0-9]}" | grep "$disk_block" &>/dev/null); then
		filesystem=$(
			eval $(blkid -o udev "$disk_block")
			printf '%s\n' "$ID_FS_TYPE"
		)

		if ! check_linuxfs $filesystem; then
			panic \
				'%s is not intended for containing a Linux system.\nDid you mean creating a virtual disk image inside %s?' \
				$filesystem "$disk_block"
		fi

		# If we have a compatible file system on the disk, we
		# shall already set as not being the first time.
		first_time=false
	fi
elif [[ "$VIRTUAL_DISK" ]]; then
	# This would be the equivalent of the old realpath() builtin
	# at posix-alt.shi, it gets $disk_block's directory location
	# and then contatenates it with its name.
	virtuadisk_path="$(
		cd "${disk_block%/*}"
		pwd -P
	)/${disk_block##*/}"
	log WARN 'Using a virtual disk, located at %s, with a pre-determined size of %d MB.' \
		"$virtuadisk_path" $((virtuadisk_size * 1024))

	if [[ ! -e $virtuadisk_path ]]; then
		log WARN 'Inexistent disk image, creating it...'
	elif [[ -e $virtuadisk_path && ! -b $virtuadisk_path ]]; then
		log WARN 'A disk image already exists at %s, do you wish to continue or clean it up and start over?' \
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
			no)
				start_over=true
				break
				;;
			quit | *) return 1 ;;
		esac
	done
fi

if "$VIRTUAL_DISK"; then
	if ($first_time || $start_over); then
		log WARN 'Creating a virtual disk image at %s, with size of %d MB.' \
			"$virtuadisk_path" $((virtuadisk_size * 1024))

		# Just remake the image if it is a new disk.
		if ! $start_over; then
			# 1 GB is equal to 2.097.152 blocks.
			# In other words, use:
			# X GB = X * [(1024^2) * 2] blocks
			virtuadisk_blksize="$((virtuadisk_size * ((1024 ** 2) * 2)))"
			dd if=/dev/zero of="$virtuadisk_path" bs=512 count=$virtuadisk_blksize
		fi

		# Does the size in blocks matches with what du(1)'s getting?
		virtuadisk_reported_size=$(du -s "$virtuadisk_path" | nawk '{ printf("%d", $1); }')
		if ((virtuadisk_blksize == virtuadisk_reported_size)); then
			log INFO '%s is o.k. Proceeding.' "$virtuadisk_path"
		else
			log WARN 'dd failed to write %d blocks to %s.' \
				$virtuadisk_blksize "$virtuadisk_path"
			log WARN 'It possible reported an error and/or an interruption signal before this message.'
			log ERROR 'Please, check. Stopping the build process.'
		fi

		# For some reason, echo won't be working for this, so let be
		# sticking with printf '%s\n'.
		printf '%s\n' "${fdisk_steps[@]}" | elevate fdisk "$virtuadisk_path"
	fi

	# Expose the virtual disk to the system.
	loop_disk_block="$(elevate losetup --show -P -f "$virtuadisk_path")"

	# That's why we hardcoded the partition to be the first.
	unset disk_block
	export disk_block="${loop_disk_block}p1"
fi
if ($first_time || $start_over); then
	echo -n >"$made"
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

log INFO 'Copacabana disk %s mounted at %s.' "$disk_block" "$COPA"
