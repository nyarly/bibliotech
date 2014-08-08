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
  end
end
