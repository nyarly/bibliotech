module BiblioTech
  class CommandGenerator::MySql < CommandGenerator

    def export(options = {})
      command = cmd('mysqldump')
      command.options << "-h #{config[:host]}"               if config[:host]
      command.options << "-u #{config[:username]}"           if config[:username]
      command.options << "--password='#{config[:password]}'" if config[:password]
      command.options << "#{config[:database]}"
      command = output_to_file(command, options)             if options[:filename]
      command
    end

    def import(options = {})
      command = cmd('mysql')
      command.options << "-h #{config[:host]}"               if config[:host]
      command.options << "-u #{config[:username]}"           if config[:username]
      command.options << "--password='#{config[:password]}'" if config[:password]
      command.options << "#{config[:database]}"
      command = input_from_file(command, options)            if options[:filename]
      command
    end

  end
end
