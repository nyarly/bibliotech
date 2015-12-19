# BiblioTech

Database backup and transfer management gem for web applications. (Used in Rails, but fairly agnostic.)

[![Code Climate](https://codeclimate.com/github/LRDesign/BiblioTech.png)](https://codeclimate.com/github/LRDesign/BiblioTech)
[![Build Status](http://ci.lrdesign.com/projects/2/status.png?ref=master)](http://ci.lrdesign.com/projects/2?ref=master)

## Features

* Backup/dump rake tasks for SQL databases
* Restore/import rake tasks for SQL databases
* Configurable backup directory pruning (Keep hourly for N days, daily for M weeks, etc.)
* Rake tasks for remote/local DB syncing

## Possible Future Features

* Capistrano tasks
* Non-SQL databases
* Management of backup transfer to S3 / Glacier / other long term storage
* Non-database backups - e.g. snapshotting of volumes

## Use Cases

### Quick database dumps and reload
```
bibliotech dump quick-dump.sql
bibliotech load quick-dump.sql
```

### Database backups

In your `Rakefile` add a line like:

    BiblioTech::Tasklib.new

You'll get some new tasks:

    rake bibliotech:backups:perform[prefix]  # Run DB backups, including cleaning up the resulting backups
    rake bibliotech:backups:restore[name]    # Restore from a named DB backup
    rake bibliotech:remote_sync:down         # Pull the latest DB dump from the remote server into our local DB
    rake bibliotech:remote_sync:up           # Push the latest local DB dump to the remote server's DB


You'll probably want to add something like:

   `17 * * * * cd <project_root> && bundle exec rake bibliotech:backup:perform`

to the appropriate crontab. Bibliotech doesn't load the whole Rails stack, so
it's quick to run the backup task when it isn't needed.

Because of that, once you've updated your Rakefile, you may prefer to use the
`backups:perform` and `backups:restore` - dump doesn't consider whether a
backup is needed.

### Development database syncronization

Check that in `config/bibliotech/config.yaml` you've got something like
```yaml
local: development
remote: staging #could be production

staging:
 #you'll need to update these
 # they're the SSH configuration to connect to the
 # staging server
  user: root
  host: some.server.com
  path: "/var/www/staging.someapp.com/current"
```

Now
```
rake bibliotech:remote_sync:down
```

will pull the most recent backup on the `remote` server and load it into your `local` database.


## Configuration

The primary way to configure Bibliotech is by putting config.yaml files in its
search path `(/etc/bibliotech /usr/share/bibliotech ~/.bibliotech ./.bibliotech
./config/bibliotech)` - files will be loaded in order, and later files will
override the configuration of earlier files.

Several configuration options can be overriden with options to various rake
tasks, as well as options on the Tasklib itself.

Configuration only needs to be set for commands that use it, so if you're not
going to doing cronjob backups, you can leave out the 'keep' schedule.
Missing fields will be reported as errors when running a command.

You can check the currently active configuration with

    bibliotech config

One use case supported by the load process is having a set of overall defaults
for an application in `.bibliotech/config.yaml` and then per-environment
configs in `config/bibliotech/config.yaml` - most commonly, the local and
remote settings are per-enviroment, and everything else is common.

Related: you may want to add a `config/bibliotech/config.yaml` to your
deployment scripts when using bibliotech

Generally, you'll want to put `.bibliotech/config.yaml' under version control
and exclude config/bibliotech/config.yaml from version control

The overall form of the config can be understood by reviewing the defaults:

    local: development
    remote: staging

    #defaults
    database_config_file: 'config/database.yml'   # this is the default
    backups:
      dir: db_backups
      compress:  gzip   # [ none, gzip, bzip2, 7zip ]
      prefix: backup
      retain:
        periodic:
          hourlies: 1
      frequency: hourly

    log:
      target: log/backups.log
      level: warn

    production:
      backups:
        retain:
          periodic:
            hourlies:   48
            dailies:    14
            weeklies:   8
          calendar:
            monthlies: 12
            quarterly: all

      database_config_env: production

      user: root
      host: some.server.com
      path: "/var/www/someapp.com/current"
      compress: gzip

    staging:
      database_config_env: staging
      path: "/var/www/staging.someapp.com/current"

      user: root
      host: some.server.com

    development:
      log:
        target: stderr
      database_config_env: development
      path: "."
      rsa_files:
        staging: "id_rsa"
        production: "id_rsa"

### Backup frequency and retention

Bibliotech does not, itself, run on any regular schedule. That's why you'll
need to configure a cronjob to do that.

All durations and times in Bibliotech are considered at a minute-level
precision. Whenever a number is used for e.g. backup frequency, it is a number
of minutes (as opposed to seconds or hours etc).

Whenever it's run, Bibliotech checks the appropriate `backups>frequency`
setting, and compares that to the most recent backup, creating a new backup if
the elapsed time is longer than the frequency.

Then Bibliotech considers the retention schedule. Without limits on retention,
backups would grow without bound, and eventually consume all available storage.

The `backups>retain>periodic` and `backups>retain>calender` settings determine
which backups will be retained. In all cases, the sense of an entry like
`interval: count` is "Keep the most recent <count> backups separated by
<interval>." Bibliotech tries very hard to keep the best, most stable version
of these backups.

The preferred method of specifying backups is using their English names: the
period names are: `hourly daily weekly monthly yearly` (or their plural forms,
like `hourlies`). Calendar intervals are `daily monthly quarterly` plus
specific quarters ("first_quarter") - these are always on the first day of
their interval. Both forms have less readable, but more flexible numeric
versions.

### The backups directory

Bibliotech assumes that it has complete control over the backups directory
(which is `db_backups` within the the project path by default). Files created
or renamed within that directory can confuse Bibliotech, and its error messages
in these cases can be confusing. (This is considered a bug, with discussion
about how to address underway.) For the moment, simply avoid creating files in
Bibliotech's directory.

## Credits

Evan Dorn and Judson Lester of Logical Reality Design, Inc.
