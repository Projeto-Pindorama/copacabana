# What I'll need?

Here I'll tell what do you need to build Copacabana.  

- A Linux-based operating system with the following packages (Arch Linux should do the job):
	- AT&T ksh93 >=2020.0.0 (for lemount);
	- Bzip2 >=2.7 (some packages such as Heirloom are compressed with it);
	- GNU Binutils =2.25;
	- GNU Bison >=2.7 (`/usr/{ccs/,}bin/yacc` shall be a file system hack or
	a small Shell script hack that runs it);
	- GNU Bourne-Again Shell >=3.2 (`/bin/sh` shall be a file system hack
	to it);
	- GNU Coreutils >=6.9 *or* uutils >=0.0.8;
	- GNU Diffutils >=2.8.1;
	- GNU Findutils >=4.2.31;
	- GNU awk >=4.0.1 (`{/usr,}/bin/awk` shall be a file system hack to it);

		:	Most of the time `nawk` (a.k.a "One True AWK") do the job perfectly,
			but we never know if someone is going to use some GNU extension so
			better safe than sorry.

	- GNU grep >=2.5.1;
	- GNU libc >=2.11 *or* Musl libc >=1.20;
	- GNU m4 >=1.4.10;
	- GNU make >=4.0;
	- GNU patch >=2.5.4;
	- GNU sed >=4.1.5;
	- GNU tar >=1.22 *or* star >=1.6;
	- Linux >=3.2;
	- Python >=3.4;
	- The complete GNU Compiler Collection >=6.2;
	- Pindorama [lemount](https://github.com/Projeto-Pindorama/lemount) >=0.1-b;
	- Pindorama [mitzune](https://github.com/Projeto-Pindorama/mitzune) >=0.1;
	- curl >=7.79.1 (for `cmd/download_sources.sh`);
	- pigz >=2.6;
	- util-linux >=2.37.2;
	- xz >=5.0.0;

**Note**: The versions in fact doesn't matter, since every modern and maintained
distribution has all of these packages updated.  
By the way, they're mixed since some of them, such as curl, are the last
version avaliable on Arch Linux that I've just taken the version number and
pasted here. 
In short: don't worry.

- A fair bit of UNIX (more specifically Linux), Shell script and a little of C knowledge;
- Some coffee and water;
- Some good music;
- Time to spare; 
