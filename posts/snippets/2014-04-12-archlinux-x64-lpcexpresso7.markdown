---
title: Getting LPCExpresso 7 to run on arch linux 64-bit
tags: archlinux, lpcexpresso, embedded, lib32
---

You need to install a couple of lib32 libraries to get LPCExpresso to work on a 64-bit archlinux.

First set up the [multilib repo](https://wiki.archlinux.org/index.php/Multilib).

Now let's translate the files needed for Ubuntu 64bit according to the user guide to arch 64 packages:

    libgtk2              -> multilib/lib32-gtk2
    libxtst6             -> multilib/lib32-libxtst
    libpangox            -> multilib/lib32-pango
    libidn11             -> multilib/lib32-libidn
    libglu1-mesa         -> multilib/lib32-glu
    libncurses5          -> multilib/lib32-ncurses
    libudev1             -> multilib/lib32-systemd
    libpangox-ft         -> aur/lib32-pangox-compat
    libusb-1.0           -> aur/lib32-libusb
    libusb-0.1           -> aur/lib32-libusb-compat
    gtk2-engines-murrine -> aur/lib32-gtk-engine-murrine

Install those packages. I use [cower](https://github.com/falconindy/cower) to install stuff from aur.

Now grab the LPCExpresso Installer from the [LPCExpresso linux download page](http://www.lpcware.com/lpcxpresso/downloads/linux) and run it. Reboot.

You should be done!
