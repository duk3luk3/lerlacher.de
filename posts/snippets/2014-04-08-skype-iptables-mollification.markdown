---
title: Skype iptables mollification in arch
tags: skype, iptables, archlinux
---

I have the same problem as [Erich Schubert](http://www.vitavonni.de/blog/201107/2011072601-restricting-skype-via-iptables.html) with Skype in my university network: Skype's crazy network behaviour gets me kicked out for being a spambot / torrenter / whatever.

Here's how to do the same thing in arch:

    sudo groupadd skype                      # might already exist
    sudo chown root:skype /usr/bin/skype
    sudo chmod g+s /usr/bin/skype

    sudo iptables -I OUTPUT -p tcp -m owner --gid-owner skype -m multiport ! --dports 80,443 -j REJECT
    sudo iptables -I OUTPUT -p udp -m owner --gid-owner skype -j REJECT
    sudo iptables-save | sudo tee /etc/iptables/iptables.rules
