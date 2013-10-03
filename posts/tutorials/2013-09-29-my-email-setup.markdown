---
title: My E-Mail setup
tags: email, postfix
---

I run my own email setup on this server (Please don't use this info to hack me). The default options here are Postfix and Dovecot.

There are dozens of postfix tutorials around. I mainly used [this one](http://shisaa.jp/postset/mailserver-1.html). You should probably read it in order to gain an understanding of how the email system works and how postfix and dovecot tie into that, because I will only touch on that rather lightly.

## Postfix ##

Postfix has two main config files: `main.cf`, which specifies what you would think of as config options, and `master.cf`, which specifies the services postfix should run (Postfix is not a single server, it runs several daemons).

For my setup, I need:

* TLS/SASL, because it's 2013
* No relay
* Dovecot integration
* Support for luser mail as well as virtual mailboxes

First we create a mailbox user that will be used by postgres and dovecot to access actual maildirs.

    groupadd -g 500 mailreader    
    useradd -g mailreader -u 500 -d /home/mail -s /sbin/nologin mailreader

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

This config - although it may not be obvious - sets up the virtual mailboxes as a fallback if mails cannot be delivered to a local luser.

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
    user=$mailboxuser
    password=$password
    dbname=mail
    table=transports
    select_field=transport
    where_field=domain
    hosts=localhost

## Postgres ##

First, give the `postgres` user a password:

    sudo -u postgres psql
    ALTER USER postgres PASSWORD 'your-new-password';
    \q

Then, put appropriate access rules into `pg_hba.conf` (could be in `/etc/postgresql/9.1/main/pg_hba.conf` or similar). For eample:

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
    CREATE TABLE transports (
        domain text NOT NULL,
        gid integer NOT NULL,
        transport text NOT NULL
    );
    CREATE TABLE users (
        email text NOT NULL,
        password text NOT NULL,
        maildir text NOT NULL,
        created timestamp with time zone DEFAULT now(),
     );

     ALTER TABLE users OWNER TO mailreader;
     ALTER TABLE transports OWNER TO mailreader;
     ALTER TABLE aliases OWNER TO mailreader;

The `aliases` table should be clear. The `transports` table determines which transports postgres should use for a domain, and includes an additional field overriding the gid to use while handling mail for that domain. Add, for example:

    INSERT INTO transports (
        domain, 
        gid,
        transport
    ) VALUES (
        'yourdomain.tld',
        500,
        'virtual:'
    );

The `users` table does not require a `uid` or `gid` field in my usecase, since all users in that table are virtual mailboxes that are all handled by the same mailreader user (we set that up with the `virtual_uid_maps` and `virtual_gid_maps` setting in postgres. We will do the same in dovecot).

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
