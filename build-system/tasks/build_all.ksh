# This will be used in Alambiko when installing the "packages" to a destination
# directory.
package_dir="$trash/pkg"

# And this will be used inside driver.ksh to find where packages/ is.
export progdir

# Syntax: build [stage_name] packages ...
function build {
	case $1 in
		cross-tools) shift; build_xtools $@ ;;
		tools) shift; build_tools $@ ;;
		base) shift; build_base $@ ;;
	esac
}

function build_xtools {
	packages=( $@ )
	n_packages=$(n ${packages[*]})
	for (( n=0; n < n_packages; n++ )); do
		# GNUcc pkgbuild will use it in a kind of messy way to determine
		# if we're building stage 1 of cross-tools' G.C.C. or not.
		(( n == 2 )) && export n; 
		"$progdir/build-system/internals/cmd/driver.ksh" -i ${packages[$n]} 
	done
}

function build_tools {
	return 0
}

function build_base {
	return 0
}

build $@
