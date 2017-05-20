---
title: Etherpad db migration
tags: sqlite, postgres, etherpad
---
Etherpad-Lite uses the same key-value-store abstraction for all the databases it uses. At least it does for sqlite, MySQL, and Postgres.

So you have a `etherpad.db.sqlite` file and want to migrate that into a postgres db because you think a real dbms might be faster.

Some people [try to do it with node](//stackoverflow.com/questions/18694659/best-way-to-migrate-huge-sqlite-databases-in-etherpad-lite), but why would you do that?

    psql -U postgres
    CREATE USER etherpad WITH PASSWORD 'foo';
    CREATE DATABASE etherpad WITH OWNER etherpad;
    \q

Now you want to take down your etherpad-lite instance.

    sqlite3 var/etherpad.sqlite.db .dump > etherpad.sqlite.dump
    psql -U etherpad -d etherpad < etherpad.sqlite.dump 
    
Edit your etherpad settings.json file and set the db config to postgres. Put in the connection info and password.
Start etherpad.

Bob's your uncle.
