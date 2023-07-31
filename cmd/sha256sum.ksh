#!/usr/bin/env ksh93
# sha256sum.ksh - Generate SHA256 hashes for a file using Open/LibreSSL.  
# Can be extended to more digest formats later, the code is pretty maleable.
#
# Copyright (c) 2023 Pindorama
# 		Luiz Antônio Rangel
# SPDX-Licence-Identifier: NCSA

progname=${0##*/}
set -e

# OpenSSL shell API binary name
SSL_CMD=${SSL_CMD:-openssl}

# Initialize "CLASSIC" as false
CLASSIC=false

function main {
	while getopts ":oC:c:h:" options; do
		case "$options" in
			C|c) check "$OPTARG" ;;
			h) hashfile="$OPTARG" ;;
			o) CLASSIC=true ;;
			\?|*) print_help ;;
		esac
	done
	shift $(( OPTIND - 1 ))

	# As done later, for the sake of readability.
	# Nobody knows exactly what "$1" means without having to read the entire
	# function before.
	file="$1"

	# If "$hashfile" isn't specificed, we will just default tee(1) output to
	# the null device, so we will not have our screen being bombed by its error
	# messages "tee: cannot open". It still printing to the standard output.
	# Business as usual.
	output_hashfile="${hashfile:-/dev/null}"

	get_checksum "$file" | tee -a "${output_hashfile}"
}

function get_checksum {
	# This generates a SHA256 hash for the input file.
	# This function doesn't treat real paths, it's just an interface.
	# $CLASSIC is a boolean-type value (true or false), and determines if
	# you're getting the old/classic OpenSSL shell API output or you're
	# getting a more cksum(1)-style output.
       
	sslcmd dgst -sha256 "$1" | \
	if ! $CLASSIC; then
		nawk_ssl_to_cksum
	else
		cat
	fi
}

# This checks if the checksum inside a file matches with the file in the disk. 
function check {
	# Just for the sake of readability, as in main.
	hashfile="$1"

	while read cksum_line; do
		# If we're using the cksum-like format (! $CLASSIC), the process
		# of parsing and comparing will be a lot less laborous.
		# Anyway, we'll be transforming the OpenSSL syntax to
		# cksum-like when comparing.
		# This will check both if $CLASSIC is true or if the
		# checksum_line will match the
		# "ALGORITHM(/path/to/file)= [0-9a-f]" pattern, which is the
		# "classic" one.
		if $CLASSIC || [[ "$cksum_line" =~ (.*\(.*\)\= .*) ]]; then
			# Abusing shell's immutability.
			# Functional fellas gonna hate it.
			cksum_line="$(printf '%s' "$cksum_line" | nawk_ssl_to_cksum)"
		fi
		file_to_check="${cksum_line#* }"
		file_alleged_hash="${cksum_line%% *}"
		
		# Setting $CLASSIC as "false", since we're going to only use
		# cksum-like syntax.
		export CLASSIC="false"

		# Same thing from before, but now with the newly generated digest.
		actual_file_cksum="$(get_checksum "${file_to_check}")"
		actual_file_name="${actual_file_cksum#* }"
		actual_file_hash="${actual_file_cksum%% *}"

		if [[ "$file_alleged_hash" == "$actual_file_hash" ]]; then
			printmsg "(SHA256) %s: OK\n" "$actual_file_name"
		else
			printmsg "(SHA256) %s: FAILED\n" "$actual_file_name"
			printmsg "%s: WARNING: %s computed checksum did NOT match\n" \
				"$progname" "$actual_file_name"
		fi
		
		# Clean variables from the memory
		unset cksum_line actual_file_cksum file_to_check \
		file_alleged_hash actual_file_name actual_file_hash
	done < "$hashfile"
	exit 0
}

# Boilerplate to OpenSSL-compatible shell API.
function sslcmd { 
	"$(type -p $SSL_CMD)" "$@"
}

# This function is a boilerplate to (N)AWK's code, which transmutes the OpenSSL
# format (called "STYLE_MD5" by OpenBSD folks on their implementation) to the
# more common cksum-like format.
function nawk_ssl_to_cksum {
	nawk '{ split($0, digest, "= ");
		sub(/.*[(]/, "", digest[1]);
		sub(/[)].*/, "", digest[1]);
		printf("%s %s\n", digest[2], digest[1]); }'
}

function printmsg {
	printf "$@" 1>&2
}

function print_help {
	printmsg \
	'usage: %s: [-o] [-C hashfile to read] [-h hashfile to record] [file to hash]\n' \
	"$progname"
	exit 1
}

main "$@"
