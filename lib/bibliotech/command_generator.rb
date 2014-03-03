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

    def export(config, filename = nil)
      raise NotImplementedError
    end
    def import(config, filename = nil)
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

  end
end

require 'bibliotech/command_generator/postgres'
require 'bibliotech/command_generator/mysql'

