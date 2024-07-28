# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023-2024: Pindorama
# SPDX-Licence-Identifier: NCSA



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


