---
title: Arch linux cross-compilation adventures
tags: archlinux, kernel, x64
---

I wanted to get a kernel with CAN support onto my netbook. The netbook is an i686 machine with a 1.6GHz atom CPU. Compiling a kernel on it takes a few hours. So my goal instead was to compile it on my beefy 8-core desktop machine.

So off I set with `a kernel` in my awesomebar, leading me to the [Kernel Compilation via Arch Build System](https://wiki.archlinux.org/index.php/Kernels/Compilation/Arch_Build_System) page. So far so good. I screwed around with that a bit and produced a lot of x64 kernels.

After a while I also found [distcc](https://wiki.archlinux.org/index.php/Distcc) and from there [32-bit chroot](https://wiki.archlinux.org/index.php/Install_bundled_32-bit_system_in_Arch64).

From there on it's a piece of cake, except for

* Edit `/etc/pacman.conf` and set `Architecture = i686`
* Edit `/etc/makepkg.conf` to get proper makeflags (dat `-j8`)
* After installing the new kernel, make sure to disable `/etc/grub/10_linux.conf` - see the big red warning in [Grub mkconfig guide](https://wiki.archlinux.org/index.php/Grub#Generating_main_configuration_file)
