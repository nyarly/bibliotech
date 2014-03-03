module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(config, filename = nil)
      parts = ['pg_dump -Fc']
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts.join(" ")
    end

  end
end
