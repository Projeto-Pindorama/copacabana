mount_point="$1"
disk_block="$2"

elevate "$run_shell" -c \
	"umount -R '"$mount_point"' '"/mnt/`echo "$mount_point" | sed 's@/@@g'`"'"
if $VIRTUAL_DISK; then
	elevate losetup -D "${disk_block%%*p?}"
fi
