module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(options = {})
      command = cmd('pg_dump', '-Fc')
      command.options << "-h #{config[:host]}"      if config[:host]
      command.options << "-U #{config[:username]}"
      command.options << "#{config[:database]}"
      command = output_to_file(command,options)     if options[:filename]
      command.env["PGPASSWORD"] = config[:password] if config[:password]
      command
    end

    def import(options = {})
      command = cmd('pg_restore')
      command.options << "-h #{config[:host]}"      if config[:host]
      command.options << "-U #{config[:username]}"
      command.options << "-d #{config[:database]}"
      command = input_from_file(command,options)    if options[:filename]
      command.env["PGPASSWORD"] = config[:password] if config[:password]
      command
    end

  end
end
