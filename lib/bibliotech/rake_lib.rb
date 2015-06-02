require 'mattock'
require 'bibliotech/application'

module BiblioTech
  class Tasklib < ::Mattock::Tasklib
    setting(:app)
    setting(:config_path)
    setting(:local, nil)
    setting(:remote, nil)

    def default_configuration
      super
      self.app = App.new

      self.config_path = app.config_path
      from_hash(app.config.hash)
      @default_state = to_hash
      @default_state.delete(:app)
      @default_state.delete(:config_path)
    end

    def resolve_configuration
      configured_state = to_hash
      configured_state.delete(:app)
      configured_state.delete(:config_path)

      case [config_path == app.config_path, configured_state == @default_state]
      when [true, true]
      when [false, false]
        raise "Won't both change config path and any other setting (sorry) - put configs in a file"
        # The rationale here is that it would introduce two conflicting sets of
        # configs, which would only enhance the level of confusion possible.
        # XXX by that reasoning, if there are any non-default config files, we
        # should reject Rakefile configs, but we don't
      when [true, false]
        app.config.hash.merge!(configured_state)
      when [false, true]
        app.config_path = config_path
        app.reset
      end
      super
    end

    default_namespace :bibliotech

    def define
      directory app.config.backup_path

      in_namespace do
        namespace :backups do
          desc "Restore from a named DB backup"
          task :restore, [:name] do |task, args|
            fail ":name is required" if args[:name].nil?
            options = { :backups => { :filename => args[:name] } }
            if %r[/] =~ args[:name]
              options = { :backups => { :file => args[:name] } }
            end
            app.import(options)
          end

          task :create, [:prefix] => app.config.backup_path do |task, args|
            options = {}
            unless args[:prefix].nil?
              options[:backups] = {:prefix => args[:prefix]}
            end
            app.create_backup(options)
          end

          task :clean, [:prefix] do |task, args|
            options = {}
            unless args[:prefix].nil?
              options[:backups] = {:prefix => args[:prefix]}
            end
            app.prune(options)
          end

          desc "Run DB backups, including cleaning up the resulting backups"
          task :perform, [:prefix] => [:create, :clean]
        end

        namespace :remote_sync do
          desc "Pull the latest DB dump from the remote server into our local DB"
          task :down do
            app.remote_cli(remote, "create_backup").must_succeed!
            result = app.remote_cli(remote, "latest")
            result.must_succeed!
            filename = result.stdout.chomp

            app.get(remote, filename).must_succeed!
            app.import(:backups => { :file => app.config.local_file(filename)}).must_succeed!
          end

          desc "Push the latest local DB dump to the remote server's DB"
          task :up do
            filename = app.latest
            app.send(remote, filename).must_succeed!
            app.remote_cli(remote, "load", filename).must_succeed!
          end
        end
      end
    end
  end
end
