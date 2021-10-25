# `intro` - introduction to Pindorama/Copacabana Linux(R)

## Description  
Copacabana Linux --- some times referred just as "Pindorama Linux" or 
"Pindorama", which is wrong since "Pindorama" is the name of the 
project, not of the distribution --- , is an independent Linux(R)
distribution focused on simplicity, sanity, modularity and liberty.  

## The file system hierarchy  
Our file system hierarchy[^0] is loosely inspired on SunOS and classical BSD's[^1]
one, where you have the fundamental separation between ==Userland== and
==Systemland==, which can (and is encouraged to) be done using separate
partitions for each one.  
Below there's a table containing all Userland and Systemland directories and
its purposes.  

| Systemland     | Its purpose                                                                                                 |
|----------------|-------------------------------------------------------------------------------------------------------------|
| /var           | Variable data files                                                                                         |
| /var/tmp       | Symbolic link to /usr/tmp (for compatibility with newer programs)                                           |
| /var/spool     | Symbolic link to /usr/spool (for compatibility with newer programs)                                         |
| /var/lock      | Symbolic link to /var/run/lock                                                                              |
| /var/mail      | Symbolic link to /var/../usr/spool/mail                                                                     |
| /var/run       | Run-time variable data                                                                                      |
| /var/lib       | Variable state information                                                                                  |
| /var/lib/color | Color management information (optional)                                                                     |
| /var/lib/misc  | Miscellaneous variable data                                                                                 |
| /var/cache     | Application cache data                                                                                      |
| /var/log       | Symbolic link to /var/adm                                                                                   |
| /var/adm       | Active data collection files (replaced `/usr/adm`, so that `/usr` could be mounted read-only if needed)[^2] |
| /etc           | System-wide configuration files                                                                             |
| /etc/skel      | Symbolic link to /usr/skel                                                                                  |
| /sbin          | Essential binaries for use by the administrator                                                             |
| /sys           | Kernel and system information virtual filesystem                                                            |
| /tmp           | Small and non-reboot-persistent temporary files                                                             |
| /boot          | Static files of the boot loader                                                                             |
| /lib           | Essential shared libraries and kernel modules                                                               |
| /dev           | Device files                                                                                                |
| /bin           | Essential binaries for use by all users                                                                     |
| /proc          | Kernel information and processes virtual file system                                                        |  

| Userland        | Its purpose                                                                    |
|-----------------|--------------------------------------------------------------------------------|
| /usr            | Userland root                                                                  |
| /usr/etc        | Userland-related program configuration                                         |
| /usr/include    | Directory for include files                                                    |
| /usr/lib        | Userland-related program libraries                                             |
| /usr/lib64      | Symbolic link to /usr/lib (in case of non-multilib systems)                    |
| /usr/bin        | Userland-related non-root-exclusive program executables                        |
| /usr/sbin       | Userland-related root-exclusive program executables                            |
| /usr/ccs        | Development tools (`cc`(1), `ld`(1), `ar`(1) etc)[^3]                          |
| /usr/share      | Architecture-independent data                                                  |
| /usr/share/lib  | Architecture-independent libraries (eg. for scripting languages)               |
| /usr/share/misc | Miscellaneous architecture-independent data (eg. magic numbers, databases etc) |
| /usr/share/doc  | Non-`man`(1) documentation (eg. HTML, plain-text, reference manuals etc)       |
| /usr/share/man  | Roff manual pages                                                              |
| /usr/src        | Source code for additional programs, owned by `wsrc` group[^4]                 |
| /usr/tmp        | Big or persistent temporary files (eg. <1MB temporary file)                    |
| /usr/spool      | Application spool data                                                         |
| /usr/skel       | default dotfiles for new users                                                 |

Obviously, this isn't the best way of making a hierarchy --- ==for instance,
Apple(R) Rhapsody (and posteriorly macOS==[^5]==) used to do this in a better way,
maintaining a **really** minimal UNIX-compatible file system hierarchy==
(containing **only** basic binaries such as `cp`(1), `cat`(1), `lc`(1), `sh`(1)
etc) ==for don't sacrificing convenience for whose wanted or needed to compile or
run classical \*NIX programs, but organizing extra programs== (in other words, the
most part of the Userland in fact) ==in their proper directories (eg. Go (runtime
and compiler) would go to `/Developer`, GIMP would go to `/Applications` etc)==[^6]
--- but we decided to do it in a little more ortodox way, mostly because we
didn't wanted to have problems at the first time and because we didn't want to 
sacrifice convenience for people that are already used to Linux (including
us).  
We intend to evolve this in the future, but it will be this for now.  

## Programming  
Everything here is, for now, made with Shell script (more specifically,
`ksh93`).
We know there are better alternatives for it out there, but it's what
we have more familiarity and experience with.  

## Footnotes and references
[^0]:	refspecs.linuxfoundation.org: Filesystem Hierarchy Standard:  
	[https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)

[^1]:
	ibgwww.colorado.edu/~lessem: Understanding Unix Concepts:  
	[http://ibgwww.colorado.edu/~lessem/psyc5112/usail/concepts/filesystems/def-of-filesys.html](http://ibgwww.colorado.edu/~lessem/psyc5112/usail/concepts/filesystems/def-of-filesys.html)

[^2]:	cs.ait.ac.th/~on: Pratical UNIX & Internet Security:  
	[https://www.cs.ait.ac.th/~on/O/oreilly/tcpip/puis/ch10_01.htm](https://www.cs.ait.ac.th/~on/O/oreilly/tcpip/puis/ch10_01.htm)

[^3]:	docs.huihoo.com: Solaris Transition Guide:  
	[https://docs.huihoo.com/solaris/8/805-6331/6j5vgg6b4/index.html](https://docs.huihoo.com/solaris/8/805-6331/6j5vgg6b4/index.html)

[^4]:	openbsd.org: OpenBSD's FAQ:  
	[https://www.openbsd.org/faq/faq5.html](https://www.openbsd.org/faq/faq5.html)

[^5]:	difyel.com: MacOs Directory Structure:  
	[https://difyel.com/apple/macos/macos-directory-structure](https://difyel.com/apple/macos/macos-directory-structure/)  
	developer.apple.com: File System Programming Guide:  
	[https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW14](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW14)

[^6]:
	rhapsodyos.org: Shaw's Rhapsody Resource Page:  
	[http://www.rhapsodyos.org/system/directories/directories.html](http://www.rhapsodyos.org/system/directories/directories.html)  
