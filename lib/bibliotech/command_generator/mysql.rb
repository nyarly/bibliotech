module BiblioTech
  module MySql
    class Export < Builders::Export
      register :mysql

      def go(command)
        command.from('mysqldump')
        command.options << "-h #{config[:host]}"               if config[:host]
        command.options << "-u #{config[:username]}"           if config[:username]
        command.options << "--password='#{config[:password]}'" if config[:password]
        command.options << "#{config[:database]}"
        command
      end
    end

    class Import < Builders::Import
      register :mysql

      def go(command)
        command.from('mysql')
        command.options << "-h #{config[:host]}"               if config[:host]
        command.options << "-u #{config[:username]}"           if config[:username]
        command.options << "--password='#{config[:password]}'" if config[:password]
        command.options << "#{config[:database]}"
        command
      end
    end
  end
end
