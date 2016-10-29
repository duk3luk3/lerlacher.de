---
title: Enabling tests on a production gitlab install
tags: gitlab
---

First, edit config/database.yml to have valid credentials for `gitlabhq_development` and `gitlabhq_test` database configs. Then:

    cd /home/git/gitlab
    sudo -u git -H bash
    bundle install --deployment --without `mysql_or_postgres` aws
    bundle exec rake setup
    bundle exec rake test

To run a specific test:

    bundle exec rspec spec/foo/bar_spec.rb
