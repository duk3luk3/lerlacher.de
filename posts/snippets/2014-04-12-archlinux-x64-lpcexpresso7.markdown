---
title: Getting LPCExpresso 7 to run on arch linux 64-bit
tags: archlinux, lpcexpresso, embedded, lib32
---

You need to install a couple of lib32 libraries to get LPCExpresso to work on a 64-bit archlinux.

1. Set up the [multilib repo](https://wiki.archlinux.org/index.php/Multilib)
1. Install lib32-gtk2. This will depend on lib32-libgl. I had a bunch of file conflicts from leftover screwups I had to clear out to get that to run.
2. Install lib32-libxtst lib32-ncurses libusb
3. `sudo ln -sf /usr/lib32/libudev.so.1 /usr/lib32/libudev.so.0`
3. Grab the LPCExpresso Installer from the [LPCExpresso linux download page](http://www.lpcware.com/lpcxpresso/downloads/linux) and run it
4. reboot
5. despair because it still can't find the debugger probe
