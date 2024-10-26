: forgo
# Set directories for the next tasks.

SRCDIR="$COPA/${SRCDIR_SUFFIX:-/usr/tmp/src}"
PKGDIR="${PKGDIR:-"$COPA/usr/tmp/plaza"}"
OBJDIR="${OBJDIR:-"$COPA/usr/tmp/obj"}"

# Amend /cgnutools/bin and /llvmtools/bin to PATH
PATH="/cgnutools/bin:/llvmtools/bin:$PATH"
