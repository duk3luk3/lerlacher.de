---
title: Projects
---

## OnionPy

OnionPy is the definitive (On merit of there not being any others) python3 api wrapper for [OnionOO](https://www.torproject.org/projects/onionoo.html.en), the web interface for the Tor network status.

It supports transparent caching with a memcache backend, simple in-memory caching, or something user-defined.

Language: Python 3  
License: BSD 3-Clause (like most other Tor projects)

[Repository](https://github.com/duk3luk3/onion-py)

## ArtyCalc

A tool for the [Armed Assault 2](http://www.arma2.com) with [ACE](http://wiki.ace-mod.net/Advanced_Combat_Environment) tactical shooter game. The ACE mod introduces an extremely sophisticated artillery system with a high degree of realism.

ArtyCalc is a tool designed to help leading a simulated artillery battery in the game, mainly by allowing the recording and target calculation of fire missions transmitted to the battery by frontline leadership elements and forward observers.

Language: C#  
License: WTFPL

[Repository](https://github.com/duk3luk3/ArtyCalc.Sharp)  
[Website](https://dl.dropboxusercontent.com/u/2808338/arma2/artycalc/artycalc.html)

## DigitalOcean tutorials

I write tutorial articles about server administration for DigitalOcean.

[Postfix and Dovecot E-Mail server tutorial](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-e-mail-server-with-dovecot)  
[Postfix/Dovecot Part two: Virtual E-Mail hosting and Dovecot LMTP](https://www.digitalocean.com/community/articles/how-to-set-up-a-postfix-email-server-with-dovecot-dynamic-maildirs-and-lmtp)

## Gitlab hacks

In the course of running the infrastructure for a university course on systems programming I chose [Gitlab CE](https://github.com/gitlabhq/) to give students git repositories. This required a few modifications to integrate it deeply to make my life easier.
I think these modifications showcase quite nicely how easy it is to mod Gitlab.

[Key modification system hook](https://github.com/duk3luk3/gitlabhq/tree/system-hook-key): Extends the system hook facility to include ssh key modification events.  
[Extending user creation API](https://github.com/duk3luk3/gitlabhq/tree/useradd-api-extension): Manually creating a user from the admin interface gives that user a randomly generated password and emails it to them. For some reason this was missing from the API, so I added it, since I needed bulk creation of users and there was no reason to re-implement the password generation and e-mail sending.

## Saltstack formulas

I love salt for managing servers. I made some formulas.

[Template Formula](https://github.com/saltstack-formulas/template-formula): A sample formula with some dummy content.  
[Dirty User Sync Formula](https://github.com/duk3luk3/dirty-user-sync-formula): A saltstack formula that syncs user accounts from one server to another by copying `/etc/passwd` and `/etc/groups`, and mounting `/home` via NFS. Nasty.  
[OpenVPN Client Formula](https://github.com/saltstack-formulas/openvpn-client-formula): A saltstack formula to manage openvpn clients in a certificate-based vpn.
