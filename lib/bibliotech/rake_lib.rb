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
      case [config_path == app.config_path, configured_state == to_hash.delete(:config_path)]
      when [false, false]
      when [true, true]
        raise "Cannot both change to config path and any other setting (sorry) - put configs in a file"
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
      in_namespace do
        namespace :backups do
          task :restore, [:name] do |task, args|
            fail ":name is required" if args[:name].nil?
            options = { :backups => { :filename => args[:name] } }
            if %r[/] =~ args[:name]
              options = { :backups => { :file => args[:name] } }
            end
            app.import(options)
          end

          task :create, [:prefix] do |task, args|
            fail ":prefix is required" if args[:prefix].nil?
            app.create_backup( :backups => { :prefix => args[:prefix] } )
          end

          task :clean, [:prefix] do |task, args|
            fail ":prefix is required" if args[:prefix].nil?
            app.prune( :backups => { :prefix => args[:prefix] } )
          end

          task :perform, [:prefix] => [:create, :clean]
        end

        namespace :remote_sync do
          task :down do
            filename = app.remote_cli(remote, "latest")
            app.get(remote, filename)
            app.import(:backups => { :filename => filename})
          end

          task :up do
            filename = app.latest
            app.send(remote, filename)
            app.remote_cli(remote, "load", filename)
          end
        end
      end
    end
  end
end
