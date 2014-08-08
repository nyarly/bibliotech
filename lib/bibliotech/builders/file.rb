require 'bibliotech/builders'

module BiblioTech
  module Builders
    class File < Base
      def self.find_class(config)
        file = config.backup_file

        explicit = find_explicit(config)
        return explicit unless explicit.nil?

        _, klass = adapter_registry.find{ |pattern, klass|
          next if pattern.is_a? Symbol
          file =~ pattern
        }
        klass || identity_adapter
      rescue Config::MissingConfig
        return NullAdapter
      end

      def file
        config.backup_file
      end
    end

    class FileInput < File
      def self.identity_adapter
        IdentityFileInput
      end

      def self.find_explicit(config)
        return adapter_registry.fetch(config.expander) do
          raise "config.expander is #{config.expander.inspect} - supported expanders are #{supported_adapters.select{|ad| ad.is_a? Symbol}.join(", ")}"
        end
      rescue Config::MissingConfig
        nil
      end

      def self.registry_host
        FileInput
      end
    end

    class FileOutput < File
      def self.identity_adapter
        IdentityFileOutput
      end

      def self.find_explicit(config)
        return adapter_registry.fetch(config.compressor) do
          raise "config.compressor is #{config.compressor.inspect} - supported compressors are #{supported_adapters.select{|ad| ad.is_a? Symbol}.join(", ")}"
        end
      rescue KeyError
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

    class IdentityFileOutput < FileOutput
      def go(cmd)
        cmd.redirect_stdout(file)
        cmd
      end
    end
  end
end
