---
title: Battery Monitor Service
tags: archlinux, systemd, linux, kernel, latitude
---

The Arch wiki suggests to write udev rules to [monitor laptop battery levels](https://wiki.archlinux.org/index.php/Laptop#hibernate_on_low_battery_level), but what if your laptop doesn't create udev events?

A battery level monitor is actually quite simple to create.

Install acpi:

```
pacman -Syu acpi
```

Create service file, timer file and script:

<script src="https://gist.github.com/duk3luk3/f04a9623add7ddfda8db724ee1890b86.js?file=battmon.service"></script>
<script src="https://gist.github.com/duk3luk3/f04a9623add7ddfda8db724ee1890b86.js?file=battmon.timer"></script>
<script src="https://gist.github.com/duk3luk3/f04a9623add7ddfda8db724ee1890b86.js?file=battmon.sh"></script>

Enable and start timer:

```
systemctl enable battmon.timer
systemctl start battmon.timer
```
