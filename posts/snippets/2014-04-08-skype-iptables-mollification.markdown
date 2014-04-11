---
title: Skype iptables mollification in arch
tags: skype, iptables, archlinux
---

I have the same problem as [Erich Schubert](http://www.vitavonni.de/blog/201107/2011072601-restricting-skype-via-iptables.html) with Skype in my university network: Skype's crazy network behaviour gets me kicked out for being a spambot / torrenter / whatever.

Here's how to do the same thing in arch:

    sudo groupadd skype                      # might already exist
    sudo chown root:skype /usr/lib/skype/skype
    sudo chmod g+s /usr/lib/skype/skype

    sudo iptables -I OUTPUT -p tcp -m owner --gid-owner skype -m multiport ! --dports 80,443 -j REJECT
    sudo iptables -I OUTPUT -p udp -m owner --gid-owner skype -j REJECT
    sudo iptables-save | sudo tee /etc/iptables/iptables.rules

What this does is it changes the group of the skype binary in `/usr/lib/skype/skype` to the group called `skype` and sets the setgid bit on it as well. This means from now on skype processes will be running with the effective gid of the skype group.  
In the iptables rule we use the ipt_owner module to make the rule match only packets from the skype gid. UDP gets blocked outright and TCP is only allowed to port 80 and 443.  
Skype will cope with that and it also doesn't go crazy on those ports.

Lastly, we make the iptables rules permanent by saving them to a file that will get read on boot.

If you want to see that it's working, run

    watch iptables -vL

To see skype packets getting rejects.
