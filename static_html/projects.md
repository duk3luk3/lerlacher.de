---
title: Portfolio
---

I have a lot of projects.

<div class="tabs">

<div class="tab">
<input type="radio" id="tab-0" name="tab-group-1" checked="checked" />
<label for="tab-0">Academic</label>
<div class="tabcontent">
## Moep80211

Moep80211 is a wireless mesh network research project that I've spent a lot of my time in undergrad and graduate studies in.

Language: C  
License: GNU GPL

[Website](http://moepi.net/?page_id=12)

## The GEP-ASP Systems Programming Lab Course

For the Games Engineering Program at TUM, I helped develop and teach the "Systemnahe Programmierung bei der Spieleentwicklung" (Systems Programming in Games Development) Course. I also specced, developed and maintained the entire infrastructure for this course, consisting of a Gitlab Collab Platform, 10 BeagleBoard xM machines, a VPN, and scripts to integrate user management and tie everything together.

Language: C, ARM Assembler, Python  
License: No published works

[Website](https://gepasp.in.tum.de)

## TUfast Eco Team

TUfast is a student club at TUM that builds prototype cars for construction competitions. The main competitions, which the cars are specced for, are Formula Student, Formula Student Electric, and the Shell EcoMarathon.

For the 2014 and 2015 Eco vehicles I was responsible for the electronic control system (all components except the power electronics), first as sole developer and then as project leader.

Language: C, Python, Java  
License: No published works

[Website](http://tufast-eco.de/)
</div>
</div>

<div class="tab">
<input type="radio" id="tab-1" name="tab-group-1" />
<label for="tab-1">Gaming</label>
<div class="tabcontent">
## ArtyCalc

A tool for the [Armed Assault 2](http://www.arma2.com) with [ACE](http://wiki.ace-mod.net/Advanced_Combat_Environment) tactical shooter game. The ACE mod introduces an extremely sophisticated artillery system with a high degree of realism.  
ArtyCalc is a tool designed to help leading a simulated artillery battery in the game. It emulates the recording sheets used by real artillery direction forces and also allows to calculate pin-point fire solutions for all ballistic artillery weapons in the game.

Language: C#  
License: WTFPL

[Repository](https://github.com/duk3luk3/ArtyCalc.Sharp)  
[Website](https://dl.dropboxusercontent.com/u/2808338/arma2/artycalc/artycalc.html)

## Forged Alliance Forever

[Supreme Commander Forged Alliance](https://en.wikipedia.org/wiki/Supreme_Commander:_Forged_Alliance) is a Real Time Strategy game from 2007. Spiritual successor to Total Annihilation, it is regarded by many of its fans as the best RTS of all time. The "FA Forever" community lobby is keeping this game alive and contributors are actively working on continuing the development of the core game as well as the ancillary lobby.

Starting in June 2015, I am part of the server and netcode maintenance team.

Language: Python  
License: GPL

[Repositories](https://github.com/FAForever)  
[Website](http://www.faforever.com/)

</div>
</div>

<div class="tab">
<input type="radio" id="tab-2" name="tab-group-1" />
<label for="tab-2">Open-Source</label>
<div class="tabcontent">
## OnionPy

OnionPy is the definitive (On merit of there not being any others) python3 api wrapper for [OnionOO](https://www.torproject.org/projects/onionoo.html.en), the web interface for the Tor network status.

It supports transparent caching with a memcache backend, simple in-memory caching, or something user-defined.

Language: Python 3  
License: BSD 3-Clause (like most other Tor projects)

[Repository](https://github.com/duk3luk3/onion-py)

## Gitlab hacks

In the course of running the infrastructure for a university course on systems programming I chose [Gitlab CE](https://github.com/gitlabhq/) to give students git repositories. This required a few modifications to integrate it deeply to make my life easier.
I think these modifications showcase quite nicely how easy it is to mod Gitlab.

[Key modification system hook](https://github.com/duk3luk3/gitlabhq/tree/system-hook-key): Extends the system hook facility to include ssh key modification events. This modification has been merged into Gitlab.  
[Extending user creation API](https://github.com/duk3luk3/gitlabhq/tree/useradd-api-extension): Manually creating a user from the admin interface gives that user a randomly generated password and emails it to them. For some reason this was missing from the API, so I added it, since I needed bulk creation of users and there was no reason to re-implement the password generation and e-mail sending.

## Saltstack formulas

I love salt for managing servers. I made some formulas.

[Template Formula](https://github.com/saltstack-formulas/template-formula): A sample formula with some dummy content.  
[Dirty User Sync Formula](https://github.com/duk3luk3/dirty-user-sync-formula): A saltstack formula that syncs user accounts from one server to another by copying `/etc/passwd` and `/etc/groups`, and mounting `/home` via NFS. Nasty.  
[OpenVPN Client Formula](https://github.com/saltstack-formulas/openvpn-client-formula): A saltstack formula to manage openvpn clients in a certificate-based vpn.
</div>
</div>

<div class="tab">
<input type="radio" id="tab-3" name="tab-group-1" />
<label for="tab-3">Technical Writing</label>
<div class="tabcontent">
## DigitalOcean tutorials

I've written a few tutorial articles about server administration for DigitalOcean.

[Postfix and Dovecot E-Mail server tutorial](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-e-mail-server-with-dovecot)  
[Postfix/Dovecot Part two: Virtual E-Mail hosting and Dovecot LMTP](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-email-server-with-dovecot-dynamic-maildirs-and-lmtp)

</div>
</div>

</div>
