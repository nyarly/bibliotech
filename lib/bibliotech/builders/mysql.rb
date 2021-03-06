require 'bibliotech/builders/database'

module BiblioTech
  module Builders
    module MySql
      class Export < Builders::Export
        register :mysql
        register :mysql2

        def go(command)
          command.from('mysqldump')
          config.optional{ command.options << "-h #{config.host}" }
          config.optional{ command.options << "-u #{config.username}" }
          config.optional{ command.options << "-P #{config.port}" } #ok
          config.optional{ command.options << "--password='#{config.password}'" }
          command.options << "#{config.database}"
          command
        end
      end

      class Import < Builders::Import
        register :mysql
        register :mysql2

        def go(command)
          command.from('mysql')
          config.optional{ command.options << "-h #{config.host}" }
          config.optional{ command.options << "-u #{config.username}" }
          config.optional{ command.options << "-P #{config.port}" } #ok
          config.optional{ command.options << "--password='#{config.password}'" }
          command.options << "#{config.database}"
          command
        end
      end
    end
  end
end
