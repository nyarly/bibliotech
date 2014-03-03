module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(config, options = {})
      parts = ['pg_dump -Fc']
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts << "> " + File.join(options[:path], options[:filename])  if options[:filename] and options[:path]
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts.join(" ")
    end

  end
end
