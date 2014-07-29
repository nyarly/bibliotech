module BiblioTech
  module Postgres
    class Export < Builders::Export
      register :postgres

      def go(command)
        command.from('pg_dump', '-Fc')
        config.optional{ command.options << "-h #{config.host}" }
        config.optional{ command.env["PGPASSWORD"] = config.password }

        command.options << "-U #{config.username}"
        command.options << "#{config.database}"
        command
      end
    end

    class Import < Builders::Import
      register :postgres

      def go(command)
        command.from('pg_restore')
        config.optional{ command.options << "-h #{config.host}" }
        config.optional{ command.env["PGPASSWORD"] = config.password }

        command.options << "-U #{config.username}"
        command.options << "-d #{config.database}"
        command
      end
    end
  end
end
