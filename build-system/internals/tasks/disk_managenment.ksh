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
		dd if=/dev/zero of="$virtuadisk_path" bs=512 count="$(( virtuadisk_size * ((1024 ** 2) * 2) ))"
		# For some reason, echo won't be working for this, so let be
		# sticking with printf '%s\n'.
		printf '%s\n' "${fdisk_steps[@]}" | elevate fdisk "$virtuadisk_path"
		loop_disk_block="$(elevate losetup --show -P -f "$virtuadisk_path")"

		# That's why we hardcoded the partition to be the first.
		unset disk_block; disk_block="${loop_disk_block}p1"
	fi
	# Formats the disk block as Ext4 and label it as our defined disk label.
	elevate "$run_shell" -c "mkfs -V -t ext4 '$disk_block' && e2label '$disk_block' '$disk_label'"
	
	# We expect the "dsk" type to be the first in the array on L.E.mount, as
	# in the default /etc/leconf, so we'll be using "1" as the second
	# argument.
	printf '%s\n' "$disk_block" 1 | eval $(elevate lemount)

	# And here we go
	typeset -x COPA="$ledisk"

	printerr 'Info: Copacabana disk %s mounted at %s.\n' "$disk_block" "$COPA"
} 