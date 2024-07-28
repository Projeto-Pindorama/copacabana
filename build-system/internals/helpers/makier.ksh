# Boilerplate for running tasks.

_make(){
	td='build-system/tasks'
	lang='.ksh'
	pd="$progdir"
	tak="$1"
	
	shift # Remove '$1'
	. "$(printf '%s/%s/%s.%s' "$pd" "$td" "$tak" "$lang")" "${@:-''}"
}
