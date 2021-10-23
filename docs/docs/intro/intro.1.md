# `intro` - introduction to Pindorama/Copacabana Linux(R)

## Description  
Copacabana Linux --- some times referred just as "Pindorama Linux" or 
"Pindorama", which is wrong since "Pindorama" is the name of the 
project, not of the distribution --- , is an independent Linux(R)
distribution focused on simplicity, sanity, modularity and liberty.  

## The file system hierarchy  
Our file system hierarchy is loosely inspired on SunOS and classical BSD's[^1]
one, where you have the fundamental separation between ==Userland== and
==Systemland==, which can (and is encouraged to) be done using separate
partitions for each one.  
Below there's a table containing all Userland and Systemland directories and
its purposes.  

| Userland        | Its purpose                                                                    |
|-----------------|--------------------------------------------------------------------------------|
| /usr            | Userland root                                                                  |
| /usr/etc        | Userland-related program configuration                                         |
| /usr/include    | Directory for include files                                                    |
| /usr/lib        | Userland-related program libraries                                             |
| /usr/lib64      | Symbolic link to /usr/lib (in case of non-multilib systems)                    |
| /usr/bin        | Userland-related non-root-exclusive program executables                        |
| /usr/sbin       | Userland-related root-exclusive program executables                            |
| /usr/ccs        | Development tools (`cc`(1), `ld`(1), `ar`(1) etc)                              |
| /usr/share      | Architecture-independent data                                                  |
| /usr/share/lib  | Architecture-independent libraries (eg. for scripting languages)               |
| /usr/share/misc | Miscellaneous architecture-independent data (eg. magic numbers, databases etc) |
| /usr/share/doc  | Non-`man`(1) documentation (eg. HTML, plain-text, reference manuals etc)       |
| /usr/share/man  | Roff manual pages                                                              |
| /usr/src        | Source code for additional programs, owned by `wsrc` group[^2]                 |
| /usr/tmp        | Big or persistent temporary files (eg. <1MB temporary file)                    |
| /usr/spool      | Application spool data                                                         |

Obviously, this isn't the best way of making a hierarchy --- for instance,
Apple(R) Rhapsody used to do this in a better way, maintaining a **really**
minimal UNIX-compatible file system hierarchy (containing **only** basic
binaries such as `cp`(1), `cat`(1), `lc`(1), `sh`(1) etc) for don't
sacrificing convenience for whose wanted or needed to compile or run classical
\*NIX programs, but organizing extra programs (in other words, the most part of
the Userland in fact) in their proper directories (eg. Go (runtime and compiler)
would go to `/Developer`, GIMP would go to `/Applications`)[^3] --- but we 
decided to do it in a little more ortodox way, mostly because we didn't wanted
to have problems at the first time and because we didn't want to sacrifice
convenience for people that are already used to Linux (including us).  
We intend to evolve this in the future, but it will be this for now.  

## Programming  
Everything here is, for now, made with Shell script (more specifically,
`ksh93`).
We know there are better alternatives for it out there, but it's what
we have more familiarity and experience with.  

## Footnotes and references
[^1]:
	Understanding Unix Concepts: "Definition of a Filesystem":  
	http://ibgwww.colorado.edu/~lessem/psyc5112/usail/concepts/filesystems/def-of-filesys.html

[^2]:	OpenBSD's FAQ: "Fetching the Source Code":  
	https://www.openbsd.org/faq/faq5.html

[^3]:
	Shaw's Rhapsody Resource Page: "Directory Structure of Rhapsody":  
	http://www.rhapsodyos.org/system/directories/directories.html
