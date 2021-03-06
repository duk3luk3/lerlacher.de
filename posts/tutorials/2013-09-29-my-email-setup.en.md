---
title: My E-Mail setup
tags: email, postfix, digitalocean
---

I run my own email setup on this server (Please don't use this info to hack me). The default options here are Postfix and Dovecot.

There are dozens of postfix tutorials around. I mainly used [this one](http://shisaa.jp/postset/mailserver-1.html). You should probably read it in order to gain an understanding of how the email system works and how postfix and dovecot tie into that, because I will only touch on that rather lightly.

You should also read the [postfix config documentation](http://www.postfix.org/postconf.5.html).

For my setup, I need:

* TLS/SASL, because it's 2013
* No relay
* Dovecot integration
* Support for luser mail as well as virtual mailboxes

This tutorial is based on Debian 7.1 *wheezy*, but it should work for most OSes.

## Install packages ##

    aptitude install postfix postgres dovecot dovecot-pgsql

You probably want to

    aptitude remove exim4

## Postfix ##

Postfix has two main config files: `main.cf`, which specifies what you would think of as config options, and `master.cf`, which specifies the services postfix should run (Postfix is not a single server, it runs several daemons).

First we create a mailbox user that will be used by postgres and dovecot to access actual maildirs.

    groupadd -g 500 mailreader    
    useradd -g mailreader -u 500 -d /home/mailboxes -s /sbin/nologin mailreader

Since the internet hasn't really properly caught up to 2013, we need to run both the standard smtp daemon for use by other MTAs in addition to the "modern" submission service that we will be using from our mail clients.

So in `master.cf`, I uncommented the submission config and added options to enable SASL:

    submission inet n       -       -       -       -       smtpd
      -o syslog_name=postfix/submission
      -o smtpd_tls_wrappermode=no
      -o smtpd_tls_security_level=encrypt
      -o smtpd_sasl_auth_enable=yes
      -o smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
      -o milter_macro_daemon_name=ORIGINATING
      -o smtpd_sasl_type=dovecot
      -o smtpd_sasl_path=private/auth

In main.cf, I first enabled TLS:

    smtpd_tls_cert_file=/etc/ssl/certs/mailcert.pem
    smtpd_tls_key_file=/etc/ssl/private/mail.key
    smtpd_use_tls=yes
    smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
    smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
    smtpd_tls_security_level=may
    smtpd_tls_protocols = !SSLv2, !SSLv3

Then the domain info, network info and relay disable: (that one is important)

    myhostname = leda.lerlacher.de
    alias_maps = hash:/etc/aliases
    alias_database = hash:/etc/aliases
    myorigin = /etc/mailname
    mydestination = leda.lerlacher.de, lerlacher.de, localhost, localhost.localdomain
    relayhost = 
    mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
    mailbox_size_limit = 0
    recipient_delimiter = +
    inet_interfaces = all

Then I set the virtual mailbox config:

    local_recipient_maps = proxy:unix:passwd.byname $alias_maps $virtual_mailbox_maps
    fallback_transport = virtual
    virtual_uid_maps = static:$mailboxuser_uid
    virtual_gid_maps = static:$mailboxuser_gid
    virtual_mailbox_base = /home/mailboxes
    virtual_mailbox_maps = pgsql:/etc/postfix/pgsql/mailboxes.cf
    virtual_maps = pgsql:/etc/postfix/pgsql/virtual.cf

This config sets up the virtual mailboxes as a fallback if mails cannot be delivered to a local luser. The `local_recipient_map`s option specifies all addresses that postfix accepts mail for.  
All other mail is rejected. This is an important setting because it avoids so-called backscatter: If postfix cannot determine all valid users immediately, like when `local_recipient_maps` is unset, it will accept mail and then send a non-delivery notice later. These non-delivery notices usually hit innocent people whose addresses have been spoofed in spam and scam mails.

The pgsql config looks like this:

    ## mailboxes.cf
    user=$mailboxuser
    password=$password
    dbname=mail
    table=users
    select_field=maildir
    where_field=email
    hosts=localhost

    ## virtual.cf
    user=$mailboxuser
    password=$password
    dbname=mail
    table=aliases
    select_field=email
    where_field=alias
    hosts=localhost

Save those files to `/etc/postfix/pgsql/` and then make sure the permissions are set properly:

    chown -R root:postfix /etc/postfix/pgsql
    chmod 750 /etc/postfix/pgsql
    chmod 740 /etc/postfix/pgsql/*

## Postgres ##

First, give the `postgres` user a password:

    sudo -u postgres psql
    ALTER USER postgres PASSWORD 'your-new-password';
    \q

Then, put appropriate access rules into `pg_hba.conf` (could be in `/etc/postgresql/9.1/main/pg_hba.conf` or similar). For example:

    local all  all                    md5
    host  mail mailboxer 127.0.0.1/32 md5

The database to back this config first needs a user config:

    psql -U postgres
    CREATE USER mailreader WITH PASSWORD 'foo';
    REVOKE CREATE ON SCHEMA public FROM PUBLIC;
    REVOKE USAGE ON SCHEMA public FROM PUBLIC;
    GRANT CREATE ON SCHEMA public TO postgres;
    GRANT USAGE ON SCHEMA public TO postgres;

Note that the `mailreader` user here is for postgres only; it is completely separate from the `mailreader` user we created on the system before.

Then a database:

    CREATE DATABASE mail WITH OWNER mailreader;
    \c mail

Then tables:

    CREATE TABLE aliases (
        alias text NOT NULL,
        email text NOT NULL
    );
    CREATE TABLE users (
        email text NOT NULL,
        password text NOT NULL,
        maildir text NOT NULL,
        created timestamp with time zone DEFAULT now(),
     );

     ALTER TABLE users OWNER TO mailreader;
     ALTER TABLE aliases OWNER TO mailreader;

The `aliases` table should be clear. 

The users table will have entries like this:

    INSERT INTO users (
        email, 
        password, 
        realname, 
        maildir,
    ) VALUES (
        'foo@yourdomain.tld', 
        md5('password'), 
        'Foo Lastname', 
        'foo/'
    );

Again - this table is for virtual mailboxes only. Don't put the addresses of lusers in there.

## Dovecot ##

In Dovecot, we also need a sql setup:

    driver = pgsql
    connect = host=localhost dbname=mail user=mailreader password=$password
    default_pass_scheme = SHA512
    password_query = SELECT email as user, password, 'maildir:/home/mailboxes/'||maildir as userdb_mail FROM users WHERE email = '%u'

Save that as `/etc/dovecot/dovecot-sql.conf` and put the following into `/etc/dovecot/dovecot.conf`: (clear the entire dovecot.conf first, or at least disable the inclusion of all of the `conf.d` directory)

We use plaintext auth encapsulated in TLS, so we can't disable plaintext auth.

    disable_plaintext_auth = no

Add permission config:  `uid` and `gid` are for the virtual mailboxes, `privileged\_group` is for the luser mails in `/var/mail/`:

    mail_uid = 500
    mail_gid = 500
    mail_privileged_group = mail

For the virtual mailboxes, sql user and auth db for virtual mailboxes (the prefetch means the user identification will be done by the authentication)

    userdb {
      driver = prefetch
    }
    passdb {
      args = /etc/dovecot/dovecot-sql.conf
      driver = sql
    }

Now the user config for local users:

    userdb {
      driver = passwd
    }
    passdb {
      args = %s
      driver = pam
    }

Enable imap protocol only, automatically add a Trash and Sent folder to mailboxes
    
    protocols = " imap"
    protocol imap {
      mail_plugins = " autocreate"
    }
    plugin {
      autocreate = Trash
      autocreate2 = Sent
      autosubscribe = Trash
      autosubscribe2 = Sent
    }

We configured postfix to use dovecot as authentication provider. This is the socket dovecot runs to enable that.
    
    service auth {
      unix_listener /var/spool/postfix/private/auth {
        group = postfix
        mode = 0660
        user = postfix
      }
    }

And finally the ssl config:
    
    ssl=required
    ssl_cert = </etc/ssl/certs/yoursite.pem
    ssl_key = </etc/ssl/private/yoursite.key

If you set `ssl=yes` dovecot will accept completely unsecured plaintext authentication on port 143. Don't do that.

## The End ##

    service postfix restart
    service dovecot restart

And you should be good to go.

Oh, whenever you edit your `/etc/aliases` file for local luser aliases, run `newaliases`.

What else do you want? Probably a firewall, maybe squirrelmail as imap webclient, and maybe spamassassin and clamav to scan your mail. For the latter, please refer to the tutorial I linked in the intro right on top!
