---
title: Cyanogenmod on HTC Desire
tags: Phone
---

It's complicated.

I used
* a previously rooted HTC Desire with a pretty old version of [twrp](http://forum.xda-developers.com/showthread.php?t=2595654), and
* a CM11 M12 ROM for HTC Desire: http://forum.xda-developers.com/showthread.php?t=2549776

Steps:

* Wipe
* Format SD Card with ext4 (Recommend 512MB swap and leaving a couple GB to system partition, so with an 8GB SD-Card, set Ext to 2GB)
* Flash CM ROM
* DO NOT flash gapps
* Reboot
* Let the ROM boot (This can take 5 to 15 minutes)
* After ROM is booted let it sit for 5 minutes (yes really)
* Skip initial setup
* Open Terminal Emulator
* Run `su` and confirm Superuser permissions
* Run `as2d install`
* answer y/n/y
* Reboot into ROM, let it optimize apps, let it sit for 5 minutes again
* Reboot into recovery
* Flash gapps
* Wipe cache from Flash menu after flashing
* Reboot

You should now have a working CM11 HTC Desire.
