module BiblioTech
  class CommandGenerator::MySql < CommandGenerator

    def export(options = {})
      parts = ['mysqldump']
      parts << "-h #{config[:host]}"               if config[:host]
      parts << "-u #{config[:username]}"
      parts << "--password='#{config[:password]}'" if config[:password]
      parts << "#{config[:database]}"
      parts << output_to_file(options)
      parts.join(" ").strip
    end

    def import(options = {})
      parts = ['mysql']
      parts.unshift input_from_file(options)
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-u #{config[:username]}"
      parts << "--password='#{config[:password]}'" if config[:password]
      parts << "#{config[:database]}"
      parts.join(" ").strip
    end

  end
end
