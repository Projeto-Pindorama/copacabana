# STEP 1.5: Populate the file system
# This function will run the cmd/populate_fhs.sh script and create directories
# for the toolchains that will be built. 

# Also declare who will be our log file.
blackbox="$COPA/build.log.$CPU"

# Self-explanatory, just create the directories for the initial
# toolchain and intermediary chroot toolchain.
log INFO 'Making directories in %s for the building toolchains.' \
	"$COPA"
elevate mkdir -p "$COPA/"{cgnu,llvm}tools "$OBJDIR" "$PKGDIR"
(cd "$COPA"; ls -lah .)

# Make a symbolic link from $COPA/cgnutools to /cgnutools, the same
# for /llvmtools.
# For instance:
# {"$COPA/",/}cgnutools expands to $COPA/cgnutools /cgnutools,
# which is the input that we'd need to ln(1).
if [[ -d "$COPA/cgnutools" && -d "$COPA/llvmtools" ]]; then
	log INFO 'Symbolic linking %s to %s...' \
		{"$COPA/",/}cgnutools {"$COPA/",/}llvmtools 

	# If /cgnutools is already a symbolic link to
	# $COPA/cgnutools, then don't re-do it. Else, if it's a
	# symbolic link but it doesn't link to $COPA/cgnutools,
	# re-do it.
	# The same applies to /llvmtools.
	[[ $(realpath /cgnutools) != "$COPA/cgnutools" ]] \
	&& test -e /cgnutools && elevate rm /cgnutools
	( test -L /cgnutools \
	&& [[ $(realpath /cgnutools) == "$COPA/cgnutools" ]] ) \
	|| elevate ln -s {"$COPA/",/}cgnutools 

	[[ $(realpath /llvmtools) != "$COPA/llvmtools" ]] \
	&& test -e /llvmtools && elevate rm /llvmtools
	( test -L /llvmtools \
	&& [[ $(realpath /llvmtools) == "$COPA/llvmtools" ]] ) \
	|| elevate ln -s {"$COPA/",/}llvmtools

	(cd /; ls -l ./{cgnu,llvm}tools)
fi

log INFO 'Making directories in %s for populating the file system.' \
	"$COPA"
elevate $run_shell -c "COPA=$COPA BUILD_KSH=$BUILD_KSH $progdir/cmd/populate_fhs.sh; mkdir -p "$SRCDIR""

log INFO 'Initializing blackbox file (%s) for the build.' \
	"$blackbox"
( cd "$COPA"; elevate sh -c "> $blackbox; chown $user $blackbox" )

log INFO 'Making %s, %s, %s, %s and %s writable by the current user.' \
	$(realpaths /{cgnu,llvm}tools) "$SRCDIR" "$OBJDIR" "$PKGDIR"
elevate chown -RH "$user" /{cgnu,llvm}tools "$SRCDIR" "$OBJDIR" "$PKGDIR"
# Because of the way we implemented add_to_PATH().
log INFO 'Creating '\''bin'\'' directories for %s and %s.' /{cgnu,llvm}tools
mkdir /{cgnu,llvm}tools/bin
export blackbox SRCDIR
