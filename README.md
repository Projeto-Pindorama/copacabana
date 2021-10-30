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
a prefix -- ` ` (NULL) when it's a real disk and `v` when it's a virtual one, which will be our case in
the documentation.  

I'll describe the entire process of in fact building the system in the docs.

The documentation is actually deployed at Silicon Tabula using MkDocs + GitHub
Pages:  
http://projeto-pindorama.github.io/silicon_tabula/

## platforms
For now, it's only being compiled for x86_64, but we intend to have it running
at least in x86_64, i586 and ARM; but, if Copacabana becames popular and we got
more resources for the distribution, we can port it for other architectures as
well.

## spread the word!
Kayo Henrique made some cool badges for Copacabana, they're avaible at our
[artworks repository](https://github.com/Projeto-Pindorama/artworks).  
We strongly encourage that you use these badges freely over the Net and the real
life.  
Put them in your website, stick them on your Workstation or Laptop, use it
freely --- within the bounds of good taste and common sense, of course.  

Badge for x64:  
![](https://raw.githubusercontent.com/Projeto-Pindorama/artworks/master/Adesivo%20Pindorama%20Copacabana/Adesivo%20Pindorama%20x64.png)  

Badge for x86:  
![](https://raw.githubusercontent.com/Projeto-Pindorama/artworks/master/Adesivo%20Pindorama%20Copacabana/Adesivo%20Pindorama%20x86.png)  

Badge for ARM:  
![](https://raw.githubusercontent.com/Projeto-Pindorama/artworks/master/Adesivo%20Pindorama%20Copacabana/Adesivo%20Pindorama%20ARM.png)  

## credits and acknowledgements
Luiz Antônio Rangel (`takusuman`), for the most part of the work --- including making Heirloom and lobase work;  
Caio Novais (`chexier`), for fixes and hacks with Shell script and dotfiles;  
Kayo Henrique (`Tamboru`) for all the graphics-related work. Seriously, the distribution
and the project itself wouldn't even have a logo if it wasn't him.  

And obviously, Copacabana wouldn't even exist if it wasn't the work of Linus
Torvalds and thousands of millions of contributors in the [Linux
kernel](http://kernel.org), neither without Gerard Beekmans' [Linux from
Scratch](http://www.linuxfromscratch.org/) manual.  
