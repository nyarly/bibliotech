module BiblioTech
  class CommandGenerator

    class << self
      def register(adapter_name, klass)
        @adapter_registry ||={}
        @adapter_registry[adapter_name] = klass
      end

      def supported_adapters
        @adapter_registry.keys
      end

      def for(config)
        @adapter_registry[config[:adapter]].new
      end
    end

    def export(config, options = {})
      raise NotImplementedError
    end
    def import(config, options = {})
      raise NotImplementedError
    end
    def wipe(config)
      raise NotImplementedError
    end
    def delete(config)
      raise NotImplementedError
    end
    def create(config)
      raise NotImplementedError
    end

    def output_to_file(options)
      return unless options[:filename] and options[:path]
      parts = []

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      parts << "| #{options[:compressor]}" if gzip?(options)
      file = File.join(options[:path], options[:filename])
      file << '.gz' if gzip?(options)
      parts << "> " + file
      parts.join(' ').strip
    end

    def input_from_file(options)
      return unless options[:filename] and options[:path]

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      file = File.join(options[:path], options[:filename])
      if gzip?(options)
        "gunzip #{file} |"
      else
        "cat #{file} |"
      end
    end

    def gzip?(options)
      options[:compressor] == :gzip
    end

  end
end

require 'bibliotech/command_generator/postgres'
require 'bibliotech/command_generator/mysql'

