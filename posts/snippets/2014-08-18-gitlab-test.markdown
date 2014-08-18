---
title: Enabling tests on a production gitlab install
tags: gitlab
---

    cd /home/git/gitlab
    sudo -u git -H bash
    bundle install --deployment --without `mysql_or_postgres` aws
    bundle exec rake setup
    bundle exec rake test
