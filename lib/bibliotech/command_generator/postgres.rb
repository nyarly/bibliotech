module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(config, options = {})
      parts = ['pg_dump -Fc']
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts << output_to_file(options)
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts.join(" ").strip
    end


    private
    def output_to_file(options)
      return unless options[:filename] and options[:path]
      parts = []

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      parts << "| #{options[:compressor]}" if options[:compressor] == :gzip
      file = File.join(options[:path], options[:filename])
      file << '.gz' if options[:compressor] == :gzip
      parts << "> " + file
      parts.join(' ').strip
    end

  end
end
