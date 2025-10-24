: forgo
# Set directories for the next tasks.

SRCDIR="$COPA/${SRCDIR_SUFFIX:-/usr/src}"
PKGDIR="${PKGDIR:-"$COPA/usr/tmp/plaza"}"
OBJDIR="${OBJDIR:-"$COPA/usr/tmp/obj"}"

# Make a backup of the PATH.
OLD_PATH="$PATH"

# Set architecture to compile for.
eval cross_tuple=$(strsplit "$TARGET_TUPLE" '-')
eval target_tuple=$(strsplit "$COPA_TARGET" '-')

if [[ ${target_tuple[0]} != ${cross_tuple[0]} ]]; then
	panic 'Target and cross-toolchain architectures can not differ.'
fi

CROSS_VENDOR=${cross_tuple[1]}
COPA_VENDOR=${target_tuple[1]}
MARCH="${target_tuple[0]}"
case "$MARCH" in
	x86_64)
		ARCH='x86'
		CPU='x86-64'
		MUSL_ARCH=$MARCH
		;;
	i686)
		ARCH='x86'
		CPU=$MARCH # i686
		MUSL_ARCH='i386'
		;;
	aarch64)
		ARCH='arm64'
		CPU='armv8-a'
		MUSL_ARCH=$MARCH
		;;
	arm7*)
		ARCH='arm'
		CPU='armv7-a'
		MUSL_ARCH=$CMLFS_ARCH
		;;
	arm6*)
		ARCH='arm'
		CPU='armv6zk'
		MUSL_ARCH=$CMLFS_ARCH
		;;
	*) panic 'Architecture not supported: %s' "$MARCH" ;;
esac
export CROSS_VENDOR COPA_VENDOR MARCH ARCH CPU MUSL_ARCH
