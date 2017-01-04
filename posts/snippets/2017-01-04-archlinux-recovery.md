---
title: Archlinux Package Recovery
tags: archlinux, linux, kernel, terminal
---

My E5450 has developed a nasty freezing bug. It managed to exhibit a freeze during a pacman upgrade, which led to basically everything in /usr/lib turning into 0 byte files.

This has the great effect of init panicking during boot, which leads to the kernel panicking too and making the caps lock key flash (but otherwise keeling over completely.)

The only way to recover from this is to reinstall the whole system. Which, thanks to arch (or rather, thanks to pacman), can be done in-place from a recovery system or arch iso with almost zero loss of user data.

It's a two-step process:

1. From the outside, reinstall pacman and all its dependencies
2. chroot into the system and use the now working pacman to reinstall the entire system

## 1. Reinstalling pacman

* Boot into the arch iso
* Remind yourself of your disk layout using `blkid` and `lsblk`
* Mount the target system: `mount /dev/sdXX /mnt`
* Mount any other volumes, e.g. `mount /dev/sda1 /mnt/boot`
* Delete pacman db lock if necessary: `rm /mnt/var/lib/pacman/db.lck`
* Get all pacman dependencies: `pactree -u pacman > pacdeps`
* Reinstall pacman into target system: `pacman -r /mnt --cachedir=/mnt/var/cache/pacman/pkg --force -Syu < pacdeps`

You should now have a working pacman on the target system

## 2. Reinstall target system

* Chroot into target: `arch-chroot /mnt`
* Figure out how to get a working `archlinux-keyring` or set `SigLevel=Never` in `/etc/pacman.conf`
* Reinstall all packages: `pacman -Qnq | pacman -S --force -`

You can now reboot and your system should boot.

References:

* [Archwiki Pacman](https://wiki.archlinux.org/index.php/Pacman)
