# `intro` - introduction to Pindorama/Copacabana Linux(R)

## Description  
Copacabana Linux --- some times referred just as "Pindorama Linux" or 
"Pindorama", which is wrong since "Pindorama" is the name of the 
project, not of the distribution --- , is an independent Linux(R)
distribution focused on simplicity, sanity, modularity and liberty (as in
Enlightenment).  

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
| /var/tmp       | Symbolic link to `/usr/tmp` (for compatibility with newer programs)                                           |
| /var/spool     | Symbolic link to `/usr/spool` (for compatibility with newer programs)                                         |
| /var/lock      | Symbolic link to `/var/run/lock`                                                                              |
| /var/mail      | Symbolic link to `/var/../usr/spool/mail`                                                                     |
| /var/run       | Run-time variable data                                                                                      |
| /var/lib       | Variable state information                                                                                  |
| /var/lib/color | Color management information (optional)                                                                     |
| /var/lib/misc  | Miscellaneous variable data                                                                                 |
| /var/cache     | Application cache data                                                                                      |
| /var/log       | Symbolic link to `/var/adm`                                                                                   |
| /var/adm       | Active data collection files (replaced `/usr/adm`, so that `/usr` could be mounted read-only if needed)[^2] |
| /etc           | System-wide configuration files                                                                             |
| /etc/skel      | Symbolic link to `/usr/skel`                                                                                  |
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
| /usr/lib64      | Symbolic link to `/usr/lib` (in case of non-multilib systems)                    |
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

## Distribution (literally)
==Unlike the most part of common/mainstream Linux distributions and even
proprietary UNIXes== such as Sun Microsystems' Solaris --- I don't know about AIX,
HP-UX or other UNIXes, but I'll go by the logic of the domino effect and assume
that this type of distribution is an industry pattern --- ==we don't distribute
the **entire** distribution just as packages. Our model is inspired on OpenBSD's
one, where the system is distributed as stages.==[^7]
> *- "What do you mean m8? I will have a 60MB tarball containing just KDE?"*  

No. ==This will just apply in fact for the base system (and some other **basic** 
tools)==. 
In other words, things that normally would be packaged individually (and
installed by a normal package manager) will be packaged as a plain tarball for
its proper stage.  
For example, in a normal system, you'd have these packages for the base system:  

- Linux.5.4.89.SPARC.32bit.Copacabana.1.0.pkg
- musl.1.2.1.SPARC.32bit.Copacabana.1.0.pkg
- libressl.3.3.1.SPARC.32bit.Copacabana.1.0.pkg
- star.1.6.SPARC.32bit.Copacabana.1.0.pkg
- GNUawk.5.1.0.SPARC.32bit.Copacabana.1.0.pkg
- GHbc.5.1.1.SPARC.32bit.Copacabana.1.0.pkg
- heirloom-toolchest.070715.SPARC.32bit.Copacabana.1.0.pkg
- stripped-lobase.20211017.SPARC.32bit.Copacabana.1.0.pkg
- *and so on*

But, in Copacabana, all of this will be distributed as a single tarball that
you'd just extract in your root disk:  

- `tsukene.1.0.txz`   
	* For the kernel, we plan to let it in a separate tarball:  
		- `linux.1.0.txz`

This makes the distribution, the maintaining and even the coding of an
installer **a lot** easier to do, since we don't have to beware having
the entire system broken by a library that updated or something like.  

### But I'm an UNIX professional, I can fix my system if this happens!
> *- "Mom, cancel my meetings, slackpkg f\*cked up glibc again!"*
  
... yeah, OK, but do you have time to do it?  

I don't want to be a "practicality is always better than simplicity" here ---
it I was intending to it, I wouldn't even be writing this, I'd be using Manjaro 
with KDE Plasma and VSCode in a high-end laptop --- but I have to say that it's
not because you can that you will have enough time to do it.  

First of all: packages are not simpler than our stages, although they being
plain-tarballs in most of the time, they require a set of tools to manage them.  
I'm not saying package managers are bad in anyway, my point is that, in the
first place, the argument of "an entire tarball for the base system isn't
simple" doesn't apply here, Mmkay?  

By my experience with Linux, I think it's better to just have the base system
divided in stages and update them in one sitting with binary patches, just
when it has some important update, instead of updating package-per-package
and taking the risk of breaking the entire system down to the wire.  

### The stages itself
The format is `stage.X.Y`, where `X.Y` is the Copacabana version and `stage` is
the stage name itself; they're coming compacted with xz, since it have the best
compression ratio out there.[^8]  

- linux.X.Y
: The Linux kernel and related files.

- tsukene.X.Y
: The base system, it contains everything that you'd need to use the system.  
	**Fun fact**: =="tsukene" (付け根) is the japanese word for "root"==,
	we decided to do it as a pun on the UNIX FHS.  
	We thought about using [Tupí-Guaraní](https://en.wikipedia.org/wiki/Tupi%E2%80%93Guarani_languages) instead --- since it's the Brazilian native
	language ---, but we didn't found so much information about it
	nor an exact translator.

- doc.X.Y
: Documentation, manual pages and documentation tools (such as `nroff`).

- devt.X.Y
: Developer Tools, such as GNU Compiler Collection, m4, GNU make etc.

Any other packages will be packaged just as usual.  

## Package manager
Oh dear, package managers...  
I'm managing to create one, made in Go and based on Sun Solaris' SVR4 package
manager, since it's really simple to implement and still has some nice features,
but I won't do it in fact for now, mostly because I don't have time to spare.  
So, for now, there's no official package manager for Copacabana, so you may have 
to use some third-party one.
May I package RPM for Copacabana, since it's one of my favorite package managers
and it's part of LSB. Nix also seem to be a really good option, but I never
tested it.  
Moreover, talking about third-party package managers, [a guy at Liga dos
Programadores' Discord server said that he was using Copacabana with the Nix
package manager](https://discord.com/channels/366404358440615951/366404358952189973/899428494226903090),
which is impossible since at the time I was building the "Temporary Tools"
stage.  

## Programming  
Everything here is, for now, made with Shell script (more specifically,
AT&T's ksh93).
I know there are better alternatives for it out there, but it's what
I have more familiarity and experience with.  
In the future, I plan to start writing everything with Go.

## Footnotes and references
[^0]:
	refspecs.linuxfoundation.org: Filesystem Hierarchy Standard:  
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

[^7]:
	ftp.openbsd.org: INSTALLATION NOTES for OpenBSD/amd64 6.6:  
	[https://ftp.openbsd.org/pub/OpenBSD/6.6/amd64/INSTALL.amd64](https://ftp.openbsd.org/pub/OpenBSD/6.6/amd64/INSTALL.amd64)

[^8]:
	tukaani.org: A Quick Benchmark: Gzip vs. Bzip2 vs. LZMA:   
	[https://tukaani.org/lzma/benchmarks.html](https://tukaani.org/lzma/benchmarks.html)
