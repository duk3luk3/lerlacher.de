---
title: The Dell Latitude UEFI Adventure
tags: uefi, windows, archlinux, x64
---

Mission statement: Install Arch Linux and Windows 7 Professional on a new Dell Latitude E5450 Laptop.

## Arch linux

1. Download arch iso
2. `dd if=iso of=/dev/sdc`
3. Plug in, boot, `F12` for boot menu, boot from usb stick
4. parted: `mklabel gpt`, `mkpart ESP fat32 1MiB 513MiB`, `set 1 boot on`
5. Make partitions for Linux (ext4) and Windows (ntfs)
6. `pacstrap` as usual
7. You're done! (But you have arch now.)

## Windows

1. Use [Rufus](https://rufus.akeo.ie/) to create a bootable usb installer from a windows iso.
2. Do it again because it won't boot
3. Do it **again**
4. Finally notice that Rufus resets the Patitioning options when you select the iso
5. Select iso, set partitioning to "GPT for UEFI", set FS to Fat32
6. You still can't boot
7. Manually create a new UEFI boot entry in the System setup (The BIOS, err UEFI). Point it at `efi/boot/bootx64.efi` on the USB stick.
8. You can now boot the Windows Installer, but... it will tell you it is missing a critical "CD/DVD driver".
9. Find hilarious advice on the internet telling you that the Windows installer just somehow lost track of the usb and you should just plug it into a different port
10. Nothing you try based on this advice, including reimaging the usb installer just because, works
11. Find useful advice on the internet that points out that the Windows 7 Installer does not include USB 3.0 drivers
12. Disable USB 3.0 in the ~~BIOS~~UEFI
13. You can now install Windows!
14. But your windows has no drivers.
15. Download the enterprise driver package CAB that Dell offers you (Props!) and get it in reach of the new Windows somehow
16. But how to install this?? [The internet delivers](http://en.community.dell.com/techcenter/enterprise-client/f/4448/t/19528289).
17. The internet does not quite deliver: Make sure to start an Admin Command Prompt and `cd` to the right directory, then start the `.bat` from there, because just running the `.bat` using Right-Click and "Run as Administrator" will run it with `pwd` being `C:\Windows\system32` which notably does not include an unpacked driver cab
18. All your drivers are installed. Wow!
19. Your Windows isn't activated. It also can't be activated because it's an OEM Key.
20. [The internet delivers again](http://dellwindowsreinstallationguide.com/the-activation-backup-and-recovery-program-windows-vista-7-version/).

There you go, that wasn't so hard was it?
