---
title: Portfolio
---

Mein Portfolio umfasst so einiges - vom Aufbau der Infrastruktur für ein Informatik-Praktikum über Steuersysteme für Prototypen-Rennautos bis zu einer Echtzeitstrategie-Total-Conversion für eine Gaming-Community mit 50000 Mitgliedern.

<div class="tabs">

<div class="tab">
<input type="radio" id="tab-0" name="tab-group-1" checked="checked" />
<label for="tab-0">Academisch</label>
<div class="tabcontent">
## Moep80211

Moep80211 ist ein Forschungsprojekt zu Wireless Mesh Networking in dem ich während meines Bachelor- und Masterstudiums gearbeitet habe.

Language: C  
License: GNU GPL

[Website](http://moepi.net/?page_id=12)

## Das GEP-ASP Systemprogrammierungs-Praktikum

Für den Studiengang Games Engineering der TUM habe ich geholfen, das Praktikum "Systemnahe Programmierung bei der Spieleentwicklung" zu aufzubauen. Ich habe dazu die gesamte Infrastruktur für das Praktikum konzeptioniert, entwickelt und betrieben. Dazu habe ich die Gitlab-Kollaborationsplattform, Beagleboard xM SOCs, OpenVPN, und jede Menge Skripting um das User-Management zu implementieren und alles miteinander zu integrieren benutzt.

Language: C, ARM Assembler, Python  
License: Keine Veröffentlichungen

[Website](https://gepasp.in.tum.de)

## TUfast Eco Team

TUfast ist ein Studentenverein an der TUM der Prototypen für Konstruktionswettbewerbe entwickelt. Die Hauptwettbewerbe, für die die Fahrzeuge konzeptioniert werden, sind Formula Student, Formula Student Electric und der Shell Eco-Marathon.

Für die Saisonen 2014 und 2015 habe ich die Fahrzeugsteuerung für das Eco-Team entwickelt und gebaut, als einziger Entwickler bzw. als Projektleiter.

Language: Embedded C, Python, Java  
License: Keine veröffentlichungen

[Website](http://tufast-eco.de/)
</div>
</div>

<div class="tab">
<input type="radio" id="tab-1" name="tab-group-1" />
<label for="tab-1">Gaming</label>
<div class="tabcontent">
## ArtyCalc

Ein Software-Tool für das MilSim-Spiel [Armed Assault 2](http://www.arma2.com) mit [ACE](http://wiki.ace-mod.net/Advanced_Combat_Environment)-Mod. Der ACE-Mod beinhaltet ein hochentwickeltes Artilleriesystem mit hohem Realismusgrad.--
ArtyCalc habe ich entwickelt um die Führung einer simulierten Artilleriestellung im Spiel zu unterstützen. Es simuliert die Berechnungstafeln die von echten Artillerie-Leitstelen benutzt werden und erlaubt es, Feuerbefehle für alle ballistischen Artilleriewaffen im Spiel zu errechnen.

Language: C#  
License: WTFPL

[Repository](https://github.com/duk3luk3/ArtyCalc.Sharp)  
[Website](https://duk3luk3.github.io/ArtyCalc.Sharp/)

## Forged Alliance Forever

[Supreme Commander Forged Alliance](https://en.wikipedia.org/wiki/Supreme_Commander:_Forged_Alliance) ist ein Echtzeitstrategie-Spiel (RTS) das 2007 veröffentliche wurde. Es ist die spirituelle Fortsetzung von Total Annihilation und wird von vielen seiner Fans als das beste RTS aller Zeiten geschätzt. Die "FA Forever" Community Lobby hält das Spiel am Leben und viele freiwillige Helfer arbeiten aktiv daran das Spiel weiterzuentwickeln.

Seit 2015 arbeite ich im Netcode und Server Team mit;
Seit 2017 bin ich Maintainer des offiziellen Lobby-Clients und Server-Maintainer.

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
