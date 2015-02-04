BiblioTech
==========

Database backup and transfer management gem for web applications. (Used in Rails, but fairly agnostic.)

[![Code Climate](https://codeclimate.com/github/LRDesign/BiblioTech.png)](https://codeclimate.com/github/LRDesign/BiblioTech)
[![Build Status](http://ci.lrdesign.com/projects/2/status.png?ref=master)](http://ci.lrdesign.com/projects/2?ref=master)

Features
----------------

* Backup/dump rake tasks for SQL databases
* Restore/import rake tasks for SQL databases
* Configurable backup directory pruning (Keep hourly for N days, daily for M weeks, etc.)
* Rake tasks for remote/local DB syncing

Possible Future Features
-----------------

* Capistrano tasks
* Non-SQL databases
* Management of backup transfer to S3 / Glacier / other long term storage
* Non-database backups - e.g. snapshotting of volumes

Use
---

Add a line like:

    BiblioTech::Tasklib.new

to your Rakefile or in a lib/tasks file. You'll get some new tasks:

    rake bibliotech:backups:perform[prefix]  # Run DB backups, including cleaning up the resulting backups
    rake bibliotech:backups:restore[name]    # Restore from a named DB backup
    rake bibliotech:remote_sync:down         # Pull the latest DB dump from the remote server into our local DB
    rake bibliotech:remote_sync:up           # Push the latest local DB dump to the remote server's DB


You'll probably want to add:

   `17 * * * * cd <project_root> && bundle exec rake bibliotech:backup:perform >> log/backup.log`

to the appropriate crontab. Bibliotech doesn't load the whole Rails stack, so
it's quick to run the backup task when it isn't needed.

Configuration
-------------

The primary way to configure Bibliotech is by putting config.yaml files in its
search path `(/etc/bibliotech /usr/share/bibliotech ~/.bibliotech ./.bibliotech
./config/bibliotech)` - files will be loaded in order, and later files will
override the configuration of earlier files.

Several configuration options can be overriden with options to various rake
tasks, as well as options on the Tasklib itself.

Configuration only needs to be set for commands that use it, so if you're not
going to doing cronjob backups, you can leave out the 'keep' schedule.
Missing fields will be reported as errors when running a command.

The form of the config can be understood by reviewing the defaults:

    local: development #which of the following config sets is the local machine
    remote: staging    #likewise, which remote server you're interested in

    #defaults
    database_config_file: 'config/database.yml'   # this is the default

    production:
      backups:
        dir: db_backups
        compress:  gzip   # [ none, gzip, bzip2, 7zip ]
        prefix: backup

        frequency: hourly
        keep:
          hourlies:   24
          dailies:    7
          weeklies:   4
          monthlies:  all

      #this assumes Rails style database.yml - you can instead
      #use a database_config: entry with a verbatim mapping
      database_config_env: production

      #SSH access to this server
      user: root
      host: some.server.com
      path: "/var/www/someapp.com/current"
      compress: gzip

    staging:
      database_config_env: staging

      user: root
      host: some.server.com
      path: "/var/www/staging.someapp.com/current"

      backups:
        compress: gzip

    development:
      database_config_env: development
      path: "."
      rsa_files:
        staging: "id_rsa"
        production: "id_rsa"

Credits
-------

Evan Dorn and Judson Lester of Logical Reality Design, Inc.
