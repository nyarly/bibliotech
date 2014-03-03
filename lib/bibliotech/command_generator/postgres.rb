module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(config, filename = nil)
      parts = ['pg_dump -Fc']
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts.join(" ")
    end

  end
end
