function finish {
	if $UMOUNT_ON_EXIT; then
		unmount_and_detach "$COPA" "$disk_block"
	fi
} 
