module BiblioTech
  class CommandGenerator::Postgres < CommandGenerator

    def export(config, options = {})
      parts = ['pg_dump -Fc']
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts << output_to_file(options)
      parts.join(" ").strip
    end


    def import(config, options = {})
      parts = ['pg_restore']
      parts.unshift input_from_file(options)
      parts.unshift "PGPASSWORD=#{config[:password]}" if config[:password]
      parts << "-h #{config[:host]}"                  if config[:host]
      parts << "-U #{config[:username]}"
      parts << "-d #{config[:database]}"
      parts.join(" ").strip
    end

    private
    def input_from_file(options)
      return unless options[:filename] and options[:path]

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      #parts << "| #{options[:compressor]}" if gzip?(options)
      file = File.join(options[:path], options[:filename])
      #file << '.gz' if gzip?(options)
      return "cat #{file} |"
    end




  end
end
