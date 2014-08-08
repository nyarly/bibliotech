module BiblioTech
  module MySql
    class Export < Builders::Export
      register :mysql

      def go(command)
        command.from('mysqldump')
        config.optional{ command.options << "-h #{config.host}" }
        config.optional{ command.options << "-u #{config.username}" }
        config.optional{ command.options << "-P #{config.port}" }
        config.optional{ command.options << "--password='#{config.password}'" }
        command.options << "#{config.database}"
        command
      end
    end

    class Import < Builders::Import
      register :mysql

      def go(command)
        command.from('mysql')
        config.optional{ command.options << "-h #{config.host}" }
        config.optional{ command.options << "-u #{config.username}" }
        config.optional{ command.options << "-P #{config.port}" }
        config.optional{ command.options << "--password='#{config.password}'" }
        command.options << "#{config.database}"
        command
      end
    end
  end
end
