# The Copacabana Linux(R) distribution
![Pindorama Copacabana Linux](https://raw.githubusercontent.com/Projeto-Pindorama/artworks/master/Pindorama%20Copacabana%20Banner/Pindorama_Copacabana_Banner_Principal.png)   

This repository contains most of the resources that you'd need to build
Copacabana, in case documentation and scripts.

Most of my work here is based on Derrick's [Musl-LFS](https://github.com/dslm4515/Musl-LFS)/[CMLFS](https://github.com/dslm4515/CMLFS),
which i'm also contributing with code and fixes for. :^)  

It follows the same building model that "vanilla" LFS and Musl-LFS/CMLFS does,
so our build is divided into cross-tools, tools and the final system.  

You can already download the cross-tools stage for Copacabana 1.0 (Sunrise) from 
the "Releases" section.  

For testing, i'm using [Pindorama's Mitzune](https://github.com/Projeto-Pindorama/mitzune), 
a tool that i've developed specifically for this task.  
The virtual disk image is being mounted using [Pindorama's lemount](http://github.com/Projeto-Pindorama/lemount), 
that's why any mentions to the Copacabana mounted disk partition are prefixed
`/dsk/Xp` --- where `X` is a number, usually `0` in the documentation since this is
the only and first image that i have mounted in my host --- , and `p` is
a prefix -- ` ` when its a real disk and `v` when its a virtual one, which will be our case.  

I'll describe the entire process of in fact building the system in the docs.

## credits and acknowledgements
Luiz Antônio Rangel (`takusuman`), for the most part of the work --- including making Heirloom and lobase work;  
Caio Novais (`chexier`), for fixes and hacks with Shell script --- for example, he
did the first attempt to fix `cmd/download_sources.sh`;  
Kayo Henrique (`Tamboru`) for all the graphics-related work. Seriously, the distribution
and the project itself wouldn't even have a logo if it wasn't him.  

And obviously, Copacabana wouldn't even exist if it wasn't the work of Linus
Torvalds and thousands of millions of contributors in the [Linux
kernel](http://kernel.org), neither without Gerard Beekmans' [Linux from
Scracth](https://www.linuxfromscratch.org/) manual.  
