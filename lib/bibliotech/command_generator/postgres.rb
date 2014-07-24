module BiblioTech
  module Postgres
    class Export < Builders::Export
      register :postgres

      def go(command)
        command.from('pg_dump', '-Fc')
        command.options << "-h #{config[:host]}"      if config[:host]
        command.options << "-U #{config[:username]}"
        command.options << "#{config[:database]}"
        command.env["PGPASSWORD"] = config[:password] if config[:password]
        command
      end
    end

    class Import < Builders::Import
      register :postgres

      def go(command)
        command.from('pg_restore')
        command.options << "-h #{config[:host]}"      if config[:host]
        command.options << "-U #{config[:username]}"
        command.options << "-d #{config[:database]}"
        command.env["PGPASSWORD"] = config[:password] if config[:password]
        command
      end
    end
  end
end
