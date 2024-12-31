: forgo
# Set directories for the next tasks.

SRCDIR="$COPA/${SRCDIR_SUFFIX:-/usr/tmp/src}"
PKGDIR="${PKGDIR:-"$COPA/usr/tmp/plaza"}"
OBJDIR="${OBJDIR:-"$COPA/usr/tmp/obj"}"

# Make a backup of the PATH.
OLD_PATH="$PATH"
