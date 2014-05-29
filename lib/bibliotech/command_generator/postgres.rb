module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(options = {})
      parts = ['pg_dump -Fc']
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts << output_to_file(options)
      parts.join(" ").strip
    end


    def import(options = {})
      parts = ['pg_restore']
      parts.unshift input_from_file(options)
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts.join(" ").strip
    end

  end
end
