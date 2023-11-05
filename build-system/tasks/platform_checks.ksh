# This task script is part of Copacabana's build system.
#
# Copyright (c) 2023: Pindorama
# SPDX-Licence-Identifier: NCSA

# STEP 0: Resources, part I
# This file is part of the "step 0" of building Copacabana, it is one of the
# tools that's being used for checking resources on the machine.
# It's not a vulgar task file, since it will be called before others.
# To be honest, this needs a, let's say, "refactor". It was created back when
# the project was being desined.

function platform_checks {
# Small checks about the shell being used for running this, if not
# the more recent versions ( 2012-08-01 < ) of Korn Shell 93.
if [ -z "$BASH" ] \
	&& [ "${.sh.version}" \
	== 'Version AJM 93u+ 2012-08-01' ]; then
# Not the best way of printing, but do it since we're without the
# internal error handling capacibilities.
	printf '\
Great, it seems you'\''re using AT&T'\''s KSH-93...

%s[10]: .: syntax error at line 23: '\`''\>''\'' unexpected
Segmentation fault

But wait, this version (%s) of KSH-93 is broken.
This script will stop running here to prevent errors like that
happening when loading the internal libraries or even executing
trivial functions.

You'\''ll need to install a new version of Korn Shell to continue the
execution of this script.\n' \
	"$progname" "${.sh.version##* }" 1>&2
	exit 1
elif [ -n "$BASH" ]; then
	printf '\
It seems you'\''re running this on GNU Broken-Again Shell...

Right, but expect that some features doesn'\''t exist here, such as
the "whence" command and some "compatibility" features are implemented
incorretly. But don'\''t worry! This is written for both working on GNU'\''s
Bourne Shell and Korn Shell 93.\n' 1>&2
fi

# If we're on VirtualBox, we can't build using more than 1 thread,
# otherwise we will be getting some funky errors.
# Happens on VirtualBox 6.1.
if [[ "$(cat /sys/devices/virtual/dmi/id/board_name)" == 'VirtualBox' ]] \
	&& (( $(grep -c processor /proc/cpuinfo) > 1 )); then
printf '\
It seems like you'\''re virtualizing on Oracle VirtualBox, cool...
How many cores? %s? Right.

/usr/ccs/bin/gcc -O -fomit-frame-pointer  -D_GNU_SOURCE  -D_FILE_OFFSET_BITS=64L  -I../libcommon -I../libuxre -DUXRE -DSU3 -c pax.c -o pax_su3.o
during RTL pass: ira
explode.c: In function '\''zipexplode'\'':
explode.c:867:1: internal compiler error: Segmentation fault
  867 | }
      | ^
0x19bbad7 internal_error(char const*, ...)
        ???:0
Please submit a full bug report, with preprocessed source (by using -freport-bug).
Please include the complete backtrace with any bug report.
See <http://gcc.gnu.org/bugs.html> for instructions.
gmake[1]: *** [Makefile:352: explode.o] Error 1
gmake[1]: *** Waiting for unfinished jobs....

Well, it seems like you will probably get this type of error when compiling the
source code to an object file in Oracle VirtualBox with multiple jobs-per-thread
enabled in gmake.
For avoiding this sort of problem later on, we will be defining the nproc function
as just an alias to "echo 1".
If you wish to risk anyway, you can define "FIX_VBOX_BUILD" as "false" at '\''machine.conf'\''.\n' \
	"$(grep -c 'processor' /proc/cpuinfo)" \
	1>&2
	typeset -x FIX_VBOX_BUILD="${FIX_VBOX_BUILD:-true}"
	if $FIX_VBOX_BUILD; then
		function nproc { echo 1; }
		typeset -xf nproc;
	fi
fi
}
