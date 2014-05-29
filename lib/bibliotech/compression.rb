module BiblioTech
  class Compression

    class << self
      def register(adapter_pattern, klass)
        Compression.registry[adapter_pattern] = klass
      end

      def registry
        @adapter_registry ||={}
      end

      def supported_adapters
        @adapter_registry.keys
      end

      def for(filepath, generator)
        _, klass = @adapter_registry.find{ |pattern, klass|
          filepath =~ pattern
        }
        return generator if klass.nil?
        klass.new(generator)
      end
    end

    def initialize(generator)
      @generator = generator
    end

  end
end

require 'bibliotech/compression/gzip'
require 'bibliotech/compression/sevenzip'
require 'bibliotech/compression/bzip2'
