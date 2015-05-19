require 'bibliotech/builders/database'

module BiblioTech
  module Builders
    module Postgres
      class Export < Builders::Export
        register :postgres
        register :postgresql
        register :postgis

        def go(command)
          command.from('pg_dump', '-Fc')
          config.optional{ command.options << "-h #{config.host}" }
          config.optional{ command.env["PGPASSWORD"] = config.password }
          config.optional{ command.options << "-p #{config.port}" } #ok

          if config.local == "development"
            config.optional{ command.options << "-U #{config.username}" }
          else
            command.options << "-U #{config.username}"
          end

          command.options << "#{config.database}"
          command
        end
      end

      class Import < Builders::Import
        register :postgres
        register :postgresql
        register :postgis

        def go(command)
          command.from('pg_restore')
          command.options << '-Oc' #Don't assign ownership, clean entries
          config.optional{ command.options << "-h #{config.host}" }
          config.optional{ command.env["PGPASSWORD"] = config.password }
          config.optional{ command.options << "-p #{config.port}" } #ok

          if config.local == "development"
            config.optional{ command.options << "-U #{config.username}" }
          else
            command.options << "-U #{config.username}"
          end

          command.options << "-d #{config.database}"
          command
        end
      end
    end
  end
end
