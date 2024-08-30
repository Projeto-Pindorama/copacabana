if $UMOUNT_ON_EXIT; then
	_make 'disk/unmount_and_detach' "$COPA" "$disk_block"
fi

# Remove the trash directory with sanity tests
rm -rf "$trash"
