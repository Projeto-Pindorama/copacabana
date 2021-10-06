# The Copacabana Linux(R) distribution
This repository contains most of the resources that you'd need to build
Copacabana, in case documentation and scripts.

Most of my work here is based on Derrick's [Musl-LFS](https://github.com/dslm4515/Musl-LFS)/[CMLFS](https://github.com/dslm4515/CMLFS),
which i'm also contributing with code and fixes for. :^)  

It follows the same building model that "vanilla" LFS and Musl-LFS/CMLFS does,
so our build is divided into cross-tools, tools and the final system.  

You can already download the cross-tools stage for Copacabana 1.0 (Sunrise) from 
Pindorama's FTP server. Just enter in pindorama.twilightparadox.com (port 2121), 
it's inside the copacabana/ directory.  

For testing, i'm using [Pindorama's Mitzune](https://github.com/Projeto-Pindorama/mitzune), 
a tool that i've developed specifically for this task.  
The virtual disk image is being mounted using [Pindorama's lemount](http://github.com/Projeto-Pindorama/lemount), 
that's why any mentions to the Copacabana mounted disk partition are prefixed
`/dsk/Xp` --- where `X` is a number, usually `0` in the documentation since this is
the only and first image that i have mounted in my host.  

I'll describe the entire process of in fact building the system in the docs.
