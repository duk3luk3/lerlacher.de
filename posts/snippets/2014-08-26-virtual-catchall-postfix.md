---
title: Catch-All virtual mail domain with postfix
tags: postfix, email
---

This is a neat trick to set up a self-contained mail server for software testing purposes.

Add this to `main.cf`:

    virtual_alias_domains = testdomain.com
    virtual_alias_maps = hash:/etc/virtual-aliases

And create a `/etc/virtual-aliases` file with this:

    @testdomain.com root

Then run

    postmap /etc/virtual-aliases
    postfix reload

Now all e-mails sent to `*@testdomain.com` will end up in root's mailbox.
