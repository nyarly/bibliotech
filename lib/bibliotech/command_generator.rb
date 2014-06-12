require 'caliph'

module BiblioTech
  class CommandGenerator
    include Caliph::CommandLineDSL

    attr_accessor :config

    class << self
      def register(adapter_name, klass)
        @adapter_registry ||={}
        @adapter_registry[adapter_name] = klass
      end

      def supported_adapters
        @adapter_registry.keys
      end

      def for(config)
        @adapter_registry[config[:adapter]].new(config)
      end
    end

    def initialize(config)
      @config = config
    end

    def export(options = {})
      raise NotImplementedError
    end
    def import(options = {})
      raise NotImplementedError
    end
    def wipe()
      raise NotImplementedError
    end
    def delete()
      raise NotImplementedError
    end
    def create()
      raise NotImplementedError
    end

    def output_to_file(command, options)
      return unless options[:filename] and options[:path]

      file = File.join(options[:path], options[:filename])

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      if compressed?(options)
        file << '.gz'
        command = command | cmd(options[:compressor])
      end

      command.redirect_stdout(file)
    end

    def input_from_file(command, options)
      return unless options[:filename] and options[:path]

      file = File.join(options[:path], options[:filename])

      # TODO: modularize compressor lookup and support bunzip2 and 7zip
      if compressed?(options)
        cmd('gunzip', file) | command
      else
        cmd('cat',file) | command
      end
    end

    def gzip?(options)
      options[:compressor] == :gzip
    end
    alias compressed? gzip?  #TODO: expand this when other compressors are available

  end
end

require 'bibliotech/command_generator/postgres'
require 'bibliotech/command_generator/mysql'

