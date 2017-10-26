---
title: Bau deinen eigenen Have-I-Been-Pwned Passwortchecker
tags: hibp, linux, python, db, postgres
---

<span style="background-color: #FF9999; padding-left: 5em; padding-right: 5em;">
**Bitte lest die Hinweise unter diesem Einführungstext bevor ihr versucht das nachzubauen**.
</span>

[Have I Been Pwned](https://haveibeenpwned.com/) (HIBP) ist eine großartige Webseit von [Troy Hunt](https://troyhunt.com/) auf der man prüfen kann, ob die eigene E-Mail-Adresse in "geleakten" Benutzerdatenbanken enthalten ist und das dazugehörende Passwort darum vielleicht nicht mehr sicher ist.

Im August hat Troy Hunt dann ein ganz neues Feature dazugebaut: Die Möglichkeit, direkt Passwörter gegen seine Datenbank mit [306 Millionen geknackten Passwörtern](https://www.troyhunt.com/introducing-306-million-freely-downloadable-pwned-passwords/) zu prüfen.

Die Datenbank kann [direkt auf HIBP abgefragt werden](https://haveibeenpwned.com/Passwords) und ist auch über die [HIBP API](https://haveibeenpwned.com/API/v2#PwnedPasswords) verfügbar.

Wie Troy Hunt auch in seinem eigenen Blogpost erklärt, empfiehlt das NIST inzwischen ausdrücklich Benutzerpasswörter gegen bekannte Listen geknackter Passwörter zu prüfen.

Wenn ihr also Benutzer mit Logins habt, könnte so eine Datenbank für euch sehr nützlich sein. Auch auf mich trifft das zu.

Aber natürlich ist es eine schlechte Idee, (potenzielle) Benutzerpasswörter an eine Seite im Internet zu schicken, sogar wenn es Troy Hunt ist!

Ich habe mich also an die Arbeit gemacht und die Pwned Passwords-API nachgebaut damit ich sie in meinem eigenen (Kunden-) Netz betreiben kann.

Und hier erkläre ich wies geht!

Zutaten:

* Ein Server (Ich benutze eine VM in ESXi VMWare mit 4GB RAM und 80GB Festspeicher auf der Ubuntu 16.04 als Betriebssystem läuft)
* Eine Datenbank (PostgreSQL 9.6)
* Eine Web-Application für die API
* Die Integration für eure Registrierungs / Passwort-Seite, mit der die API abgefragt wird

Die dazugehörende Web-App findet man hier: https://github.com/duk3luk3/pwndwords

<span style="background-color: #FF9999; padding-left: 5em; padding-right: 5em;">
**Achtung**
</span>

* Die Größe der Passwortliste führt dazu dass die Datenbank ca. 16GB Daten und 11GB Index enthalten wird. Das ist nicht "Big Data" aber auch nicht mehr ganz simpel. Wenn ihr hier einen Fehler macht führt das leicht zu Datenbankoperationen die sehr lange dauern!
* Dieser Artikel ist für ein privates Deployment in einem Intranet geschrieben. Wenn ihr ein öffentliches Interface anbieten wollt, müsst ihr über Maßnahmen wie Rate-Limiting und Caching nachdenken, die ich hier nicht beachtet habe.
* Ihr solltet euren Benutzern nahelegen, Passwortmanager und zufällig generierte Passwörter und Passphrasen (Diceware!) zu benutzen. Diese API dient nicht zum bewerten von Passwort-Komplexität, was sowieso [nicht ganz trivial ist](https://nakedsecurity.sophos.com/2015/03/02/why-you-cant-trust-password-strength-meters/).

Und los gehts ~~

## Datenbank

Ich bin kein Datenbankexperte, aber das ist mir eingefallen:

* Postgres 9.6 auf Ubuntu 16.04
* 'passwords' Tabelle mit primary key, passworthash, und Index
* Ggf. zusätzliche Tabelle für andere Daten (z.B. Hit Counter)

Zuerst muss pg9.6 installiert werden:

* Apt source list Setup Anleitung hier befolgen: https://www.postgresql.org/download/linux/ubuntu/
* `sudo aptitude install postgresql-9.6`

Es ist sinnvoll die Postgres-Konfiguration anzupassen um die Arbeitsspeicher-Allokation zu tunen (besonders `shared_buffers` und `work_mem`). Im PostgreSQL-Wiki gibt es eine [Tuning PostgreSQL](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server)-Anleitung.

Einen Datenbank-User erstellen:

* `sudo -u postgres -i`
* `createuser -s -r -d erlacher`
* `logout`

Datenbank erstellen:

* `createdb passwords`

Extension (`pgcrypto` Extension für `digest` Funktion), Tabelle und Index erstellen:

```sql
CREATE EXTENSION pgcrypto;
CREATE TABLE passwords ( id bigserial PRIMARY KEY, hash bytea);
CREATE INDEX ON passwords (substring(hash for 7));
```

Damit wird ein Index über die ersten 7 bytes des SHA1-Passwort-Hashes gebaut. Für unsere Liste mit 300 Millionen Passwörtern ist das eine gute Index-Größe, da es damit kaum Kollisionen geben sollte.

## Daten laden und säubern

(In Zukunft sollte V2 der Passwort-Liste verfügbar sein, dann kann man sich diesen Schritt vielleicht sparen.)


* Dateien von https://haveibeenpwned.com/Passwords herunterladen
* Mit `p7zip -d` entpacken
* Duplikate entfernen:

```
$ time sort --parallel=4 -u pwned-passwords-1.0.txt pwned-passwords-update-1.txt pwned-passwords-update-2.txt > pwned_all_uniq.txt

real	4m35.591s
user	1m42.476s
sys	0m26.056s
```

(Ohne `--parallel` dauerte es 12 Minuten für nur die erste Datei - aber beim Aufruf mit `--parallel` war eventuell schon der Disk-Cache gefüllt)

## In die Datenbank importieren

Wenn ihr schon mit der Datenbank rumgespielt habt und sie säubern wollt bevor ihr die volle Liste importiert, könnte ihr die Tabelle truncaten:

```sql
TRUNCATE passwords RESTART IDENTITY;
```

Dann den Import starten:

```
$ sed -e 's/^/\\\\x/' pwned_all_uniq.txt | time psql passwords -c "copy passwords (hash) from STDIN"
```

Das `sed` ist hier notwending um `\\x` vor alle Hashes einzufügen damit Postgres sie als Hexadezimal-Strings erkennt.

## Query

Um den Index zu benutzen, muss eine WHERE-Condition die zum Index passt in der Query benutzt werden:

```sql
prepare pw_lookup (bytea) as select * from passwords WHERE substring(hash for 7) = substring($1 for 7) and hash = $1;
explain analyze execute pw_lookup(digest('sommernacht','sha1'));
```

Und ihr solltet eine Ausgabe wie hier erhalten:

```
                                                                QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on passwords  (cost=29579.61..2284020.12 rows=1 width=29) (actual time=16.376..16.376 rows=1 loops=1)
   Recheck Cond: ("substring"(hash, 1, 7) = '\x431ce891a0129c'::bytea)
   Filter: (hash = '\x431ce891a0129ceba34e9ef44638a6dbd065f28a'::bytea)
   Heap Blocks: exact=1
   ->  Bitmap Index Scan on passwords_substring_idx  (cost=0.00..29579.61 rows=1601472 width=0) (actual time=7.395..7.395 rows=1 loops=1)
         Index Cond: ("substring"(hash, 1, 7) = '\x431ce891a0129c'::bytea)
 Execution time: 16.396 ms
(7 rows)
```

## Webserver

Ich habe eine Flask-App geschrieben die in Apache2 mit `mod_wsgi` läuft.


Apache2, `mod_wsgi` (für Python3!) and Python3 Infrastruktur installieren:

```
sudo apt-get install apache2 libapache2-mod-wsgi-py3 python3-pip python3-venv
sudo a2enmod ssl wsgi
```

Jetzt müsst ihr eine App bauen - oder einfach meine benutzen:

```
sudo mkdir /opt/password-lookup
sudo chown erlacher:tumuser /opt/password-lookup/
git clone git@github.com:duk3luk3/pwndwords.git /opt/password-lookup
```

Die Requirements für die App kann man global installieren, oder ihr könnt ein Virtualenv benutzen. Ich mag Virtualenvs:

```
cd /opt/password-lookup
python3 -m venv .venv
cp activate_this.py .venv/bin/
. ./.venv/bin/activate
pip install -r requirements.txt
```

Da die Python3-Distribution in Ubuntu ein bisschen speziell ist, muss man `activate_this.py` kopieren.

Jetzt könnt ihr in `/etc/apache2/sites-available/default-ssl.conf` einen [Wsgi-Service](http://flask.pocoo.org/docs/0.12/deploying/mod_wsgi/) einbauen:

```
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin ADMIN@EXAMPLE.COM

		DocumentRoot /opt/password-lookup

		WSGIDaemonProcess passwords user=USER group=GROUP threads=5
		WSGIScriptAlias /passwords /opt/password-lookup/venv.wsgi

		<Directory /opt/password-lookup>
			WSGIProcessGroup passwords
			WSGIApplicationGroup %{GLOBAL}
			Order deny,allow
			Allow from all
			Require all granted
		</Directory>

		SSLCertificateFile    /etc/ssl/certs/CERTIFICATE.pem
		SSLCertificateKeyFile /etc/ssl/private/KEY.key
		SSLCACertificateFile  /etc/ssl/certs/ca-certificates.crt

```

Die in GROSSBUCHSTABEN eingetragenen Platzhalter müsst ihr entsprechend einsetzen.

## Integration

So, dieser letzte Teil ist keine Meisterleistung der Software-Kunst und besteht größtenteils aus Copy-Paste von StackOverflow, und sollte deshalb nur als Proof-of-Concept gesehen werden.

Die API selbst solltet ihr auch **nicht** öffentlich zugänglich machen außer ihr baut zuerst Rate-limiting und Caching ein.

Um sich noch ein bisschen sicherer zu fühlen, sollte man auch die Passwörter hashen bevor sie an die API geschickt werden...

jQuery AJAX code:

```
<script src="/jquery-1.10.2.js"></script>
<script>
$(function() {
//setup before functions
var typingTimer;                //timer identifier
var doneTypingInterval = 800;  //time in msa
var jqxhr;
   
//on keyup, start the countdown
$('#pwedit').keyup(function(){
    clearTimeout(typingTimer);
    $('#pwhint_pwnd').css('display','none');
    $('#pwhint_ok').css('display','none');
    $('#pwhint_error').css('display','none');
    $('#pwedit').css('background-color','');
    if ($('#pwedit').val()) {
        typingTimer = setTimeout(doneTyping, doneTypingInterval);
    }
});

//user is "finished typing," do something
function doneTyping () {
//alert('done typing');
var inputval = $('#pwedit').val();
$('#pwhint_working').css('display','');
jqxhr = $.ajax({
  url: 'https://pwndwords.in.tum.de/passwords/?password=' + encodeURIComponent(inputval),
  timeout: 5000,
  statusCode: {
    200: function(data, textStatus, xhr) {
        if (xhr == jqxhr) {
                $('#pwedit').css('background-color','#FF9999');
                $('#pwhint_working').css('display','none');
                $('#pwhint_pwnd').css('display','');
        }
    },         
    404: function(xhr, textStatus, errorThrown) {
        if (xhr == jqxhr) {
                $('#pwedit').css('background-color','#99FF99');
                $('#pwhint_pwnd').css('display','none');
                $('#pwhint_working').css('display','none');
                $('#pwhint_ok').css('display','');
        }              
    }          
  },           
  error: function(xhr, textStatus, errorThrown) {
        if (xhr == jqxhr && xhr.status != 404) {
                console.log('Error trying to reach pwndwords.in.tum.de: ' + textStatus + ' (' + errorThrown + ')');
                $('#pwhint_working').css('display','none');
                $('#pwhint_error').css('display','');
        }      
  }
});    
}
});            
</script>
```

HTML Form mit den Inputs:

```
                <table>
                        <tr>
                                <td>Old password:</td>
                                <td><input type=password name=password_old size=60 /></td>
                        </tr>
                        <tr>
                                <td>New Password:</td>
                                <td><input id='pwedit' type=password name=password_new size=60 /></td>
                                <td>
                                        <span id="pwhint_working" style="display: none;"><img src="/24px-spinner-black.gif"> Checking password, please wait.</span>
                                        <span id="pwhint_pwnd" style="background-color: #ff9999; display: none;">This password has been pwned and is not allowed.</span>
                                        <span id="pwhint_ok" style="display: none;">This password has not previously been pwned. (But that does not mean it is a good password)</span>
                                        <span id="pwhint_error" style="display: none;">There was an error checking your password :-(</span>
                                </td>
                        </tr>
                        <tr>
                                <td>Repeat New Password:</td>
                                <td><input type=password name=password_repeat size=60 /></td>
                        </tr>
                </table>
```
