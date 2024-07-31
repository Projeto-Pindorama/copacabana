# Boilerplate for running tasks.

_make(){
	lang='.ksh'
	tasks="${tasks:?"task directory not defined"}"
	tak="$1"
	
	shift # Remove '$1'
	. "$(printf '%s/%s%s' "$tasks" "$tak" "$lang")" "${@:-''}"
}
