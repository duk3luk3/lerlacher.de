---
title: Standing up your own Have-I-Been-Pwned Passwords Server
tags: hibp, linux, python, db, postgres
---

<span style="background-color: #FF9999; padding-left: 5em; padding-right: 5em;">
**Please read the caveats below this introduction before trying to play along at home**.
</span>

[Have I Been Pwned](https://haveibeenpwned.com/) (HIBP) is a great service by [Troy Hunt](https://troyhunt.com/) that allows you to check if logins (and passwords) associated with your email address have been in publicised website breaches.

In August, Troy Hunt added an entirely new feature to HIBP: Checking passwords against a database of [306 million breached passwords](https://www.troyhunt.com/introducing-306-million-freely-downloadable-pwned-passwords/) that he compiled.

This database can also be [queried on HIBP directly](https://haveibeenpwned.com/Passwords) and in the [HIBP API](https://haveibeenpwned.com/API/v2#PwnedPasswords).

As Troy Hunt explains in his own blog posts, it is now a NIST recommendation to check user passwords against known compromised passwords.

So, if you have users and maintain a database of logins for them, this is something that could be very useful for you. I am one of those people who have users with logins of passwords.

However, it is obviously a bad idea to send (potential) user passwords to someone else on the internet, even someone as trustworthy as Troy Hunt!

So I set to replicate the PwnedPasswords API so I could host it inside my (client's) own infrastructure.

Here's how to do that!

What you will need:

* A server (I am using an ESXi VMWare hosted virtual machine with 4GB of RAM and 80GB of disk running Ubuntu 16.04)
* A database (Postresql 9.6)
* A webapp for the API (I wrote a Python Flask-based app)
* An integration for your signup / password change frontend that queries the webapp

This post is accompanied by this webapp: https://github.com/duk3luk3/pwndwords

<span style="background-color: #FF9999; padding-left: 5em; padding-right: 5em;">
**Caveats**
</span>

* You will be setting up a database with approx. 16GB of data and 11GB of index. That is not big data but it's not trivial data anymore either. If you make a mistake you can easily kick off a database operation that will sit there spinning for ten minutes.
* This post is written with a private on-premises deployment in mind. If you want to make this publicly available you will need to take additional measures, e.g. rate-limiting, that have not been taken account here.
* You should recommend / urge you users to use password managers and randomly generated passwords / diceware passphrases. This API does not do anything to estimate password quality which has [its own bag of caveats](https://nakedsecurity.sophos.com/2015/03/02/why-you-cant-trust-password-strength-meters/).

And now let's go ~~

## The database

I am not an expert on databases in any way shape or form, but here is what I came up with:

* Postgres 9.6 on Ubuntu 16.04
* Main 'passwords' table with id and passwords
* Additional table for auxiliary data (e.g. hit counter)

Install pg9.6 on Ubuntu 16.04:

* Follow apt source list setup instructions here: https://www.postgresql.org/download/linux/ubuntu/
* `sudo aptitude install postgresql-9.6`

You may want to edit the postgres configuration to tune its memory allocations (especially the `shared_buffers` and `work_mem` settings). See here for [tuning PostgreSQL](https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server).

Setup a user:

* `sudo -u postgres -i`
* `createuser -s -r -d erlacher`
* `logout`

Setup a database:

* `createdb passwords`

Create extension (`pgcrypto` extension for `digest` function), table and index:

```sql
CREATE EXTENSION pgcrypto;
CREATE TABLE passwords ( id bigserial PRIMARY KEY, hash bytea);
CREATE INDEX ON passwords (substring(hash for 7));
```

This is an index on the first 7 bytes of the sha1 hash. For our list of 300 million passwords, that is a very useful index size.

## Get and clean data

(If you are reading this in the future, V2 of the password list may have been released and be clean so you might not need to do this step.)

* Download the files from https://haveibeenpwned.com/Passwords
* Unzip them with `p7zip -d`
* Clean duplicates from the files:

```
$ time sort --parallel=4 -u pwned-passwords-1.0.txt pwned-passwords-update-1.txt pwned-passwords-update-2.txt > pwned_all_uniq.txt

real	4m35.591s
user	1m42.476s
sys	0m26.056s
```

(Without `--parallel` it took 12 minutes to sort just the first file - but the 4 minutes here may be cache effects.)

## Load into database

If you've been playing around with the db and want to clean it up before loading the full list, do this:

```sql
TRUNCATE passwords RESTART IDENTITY;
```

Then load it:

```
$ sed -e 's/^/\\\\x/' pwned_all_uniq.txt | time psql passwords -c "copy passwords (hash) from STDIN"
```

The `sed` here is necessary to prepend the escape sequence `\\x` to all hashes so that pg will recognize them as hexadecimal strings.

## Query

To utilize the index, we need to invoke it by using a where condition that matches the index expression:

```sql
prepare pw_lookup (bytea) as select * from passwords WHERE substring(hash for 7) = substring($1 for 7) and hash = $1;
explain analyze execute pw_lookup(digest('sommernacht','sha1'));
```

and we get this:

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

The server will be a Flask app hosted with apache2 and `mod_wsgi`.

Install apache2, `mod_wsgi` (for Python3!) and python3 stuff:

```
sudo apt-get install apache2 libapache2-mod-wsgi-py3 python3-pip python3-venv
sudo a2enmod ssl wsgi
```

Create the app, or just clone mine:

```
sudo mkdir /opt/password-lookup
sudo chown erlacher:tumuser /opt/password-lookup/
git clone git@github.com:duk3luk3/pwndwords.git /opt/password-lookup
```

You can install the requirements into your system globally, or use a venv. I like to use venvs:

```
cd /opt/password-lookup
python3 -m venv .venv
cp activate_this.py .venv/bin/
. ./.venv/bin/activate
pip install -r requirements.txt
```

The very special python3 distribution in Ubuntu lacks `activate_this.py` so you need to copy that from the repository.

Now grab `/etc/apache2/sites-available/default-ssl.conf` and set it up to create a [wsgi service](http://flask.pocoo.org/docs/0.12/deploying/mod_wsgi/):

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

Fill in appropriate values for all the CAPITALISED placeholder values in there.

## Integration

OK, this bit is *really* gnarly and consists mainly of things copy-pasted off of StackOverflow, so please don't copy and paste this in turn, take it only as an instructive proof-of-concept.

You should also consider that ideally you should **not** have the API exposed publicly **unless** you take additional measures for rate-limiting.

This code **also** should hash the passwords with SHA-1 before submitting them to the API for just a little bit more feel-good factor.

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

HTML form part with the inputs:

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
