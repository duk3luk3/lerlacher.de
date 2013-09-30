---
title: My E-Mail setup
tags: email, postfix
---

I run my own email setup on this server (Please don't use this info to hack me). The default options here are Postfix and Dovecot.

There are dozens of postfix tutorials around. I mainly used [this one](http://shisaa.jp/postset/mailserver-1.html). You should probably read it in order to gain an understanding of how the email system works and how postfix and dovecot tie into that, because I will only touch on that rather lightly.

The punchline first:

    local_recipient_maps =

And now, for the meat.

## Postfix

Postfix has two main config files: `main.cf`, which specifies what you would think of as config options, and `master.cf`, which specifies the services postfix should run (Postfix is not a single server, it runs several daemons).

For my setup, I need:

* TLS/SASL, because it's 2013
* No relay
* Dovecot integration

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

Then I set the virtual mailbox config:

    local_recipient_maps =
    virtual_uid_maps = static:$mailboxuser_uid
    virtual_gid_maps = static:$mailboxuser_gid
    virtual_mailbox_base = /home/mailboxes
    virtual_mailbox_maps = pgsql:/etc/postfix/pgsql/mailboxes.cf
    virtual_maps = pgsql:/etc/postfix/pgsql/virtual.cf
    fallback_transport_maps = pgsql:/etc/postfix/pgsql/transport.cf

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

    ## transport.cf
    user=mailboxer
    password=$password
    dbname=mail
    table=transports
    select_field=transport
    where_field=domain
    hosts=localhost

And here is the database:
