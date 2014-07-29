require 'mattock'
require 'bibliotech/application'

module BiblioTech
  class Tasklib < ::Mattock::Tasklib
    setting(:app)
    setting(:config_path)

    def default_configuration
      super
      self.app = App.new

      self.config_path = app.config_path
      from_hash(app.config.hash)
      @default_state = to_hash.delete(:app, :config_path)
    end

    def resolve_configuration
      configured_state = to_hash.delete(:app, :config_path)
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
          task :create do
            app.export
          end

          task :restore do
            app.import
          end

          task :clean do
          end

          task :perform => [:create, :clean]
        end

        namespace :remote_sync do

        end
      end
    end
  end
end
