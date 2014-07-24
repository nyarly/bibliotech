require 'caliph'

module BiblioTech
  module Builders
    class Base
      include Caliph::CommandLineDSL
      class << self
        def register(adapter_name)
          adapter_registry[adapter_name] = self
        end

        def adapter_registry
          registry_host.registry
        end

        def registry
          @registry ||={}
        end

        def supported_adapters
          adapter_registry.keys
        end

        def for(config)
          find_class(config).new(config)
        end

        def null_adapter
          NullAdapter
        end
      end

      def initialize(config)
        @config = config
      end
      attr_reader :config
    end

    class NullAdapter < Base
      def go(cmd)
        cmd
      end
    end

    class File < Base
      def self.find_class(config)
        return NullAdapter unless config.has_key?(:filename) and config.has_key?(:path)

        if config.has_key? :compressor
          return adapter_registry.fetch(config[:compressor]) do
            raise "config[:compressor] is #{config[:compressor].inspect} - supported compressors are #{supported_adapters.select{|ad| ad.is_a? Symbol}.join(", ")}"
          end
        end

        filename = config[:filename]
        _, klass = adapter_registry.find{ |pattern, klass|
          next if pattern.is_a? Symbol
          filename =~ pattern
        }
        klass || identity_adapter
      end

      def file
        ::File.join(config[:path], config[:filename])
      end
    end

    class Database < Base
      def self.find_class(config)
        adapter_registry.fetch(config[:adapter]) do
          raise "config[:adapter] is #{config[:adapter].inspect} - supported adapters are #{supported_adapters.join(", ")}"
        end
      end
    end


    class Import < Database
      def self.registry_host
        Import
      end
    end

    class Export < Database
      def self.registry_host
        Export
      end
    end

    class FileInput < File
      def self.identity_adapter
        IdentityFileInput
      end

      def self.registry_host
        FileInput
      end
    end

    class FileOutput < File
      def self.identity_adapter
        IdentityFileOutput
      end

      def self.registry_host
        FileOutput
      end
    end

    class IdentityFileInput < FileInput
      def go(cmd)
        cmd.redirect_stdin(file)
        cmd
      end
    end

    class GzipExpander < FileInput
      register(/.*\.gz\z/)
      register(/.*\.gzip\z/)
      register :gzip

      def go(command)
        command = cmd("gunzip", file) | command
      end
    end

    class IdentityFileOutput < FileOutput
      def go(cmd)
        cmd.redirect_stdout(file)
        cmd
      end
    end

    class GzipCompressor < FileOutput
      PATTERNS = [ /.*\.gz\z/, /.*\.gzip\z/ ]
      PATTERNS.each do |pattern|
        register pattern
      end

      def go(cmd)
        cmd |= %w{gzip}
        cmd.redirect_stdout(file)
        cmd
      end
    end

    class ExplicitGzipCompressor < GzipCompressor
      register :gzip

      def file
        file = super
        unless PATTERNS.any?{|pattern| pattern =~ file}
          return file + ".gz"
        end
        file
      end
    end
  end
  class CommandGenerator

    include Caliph::CommandLineDSL

    attr_accessor :config

    def initialize(config)
      @config = config
    end

    def export(options = {})
      options = config.merge(options)
      command = cmd
      command = Builders::Export.for(options).go(command)
      Builders::FileOutput.for(options).go(command)
    end

    def import(options = {})
      options = config.merge(options)
      command = cmd()
      command = Builders::Import.for(options).go(command)
      Builders::FileInput.for(options).go(command)
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
  end
end

require 'bibliotech/command_generator/postgres'
require 'bibliotech/command_generator/mysql'
