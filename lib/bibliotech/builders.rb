module BiblioTech
  module Builders
    class Base
      include Caliph::CommandLineDSL

      class AdapterRegistry
        def initialize
          @hash = {}
          @has_regexp = false
        end

        def put(name, value)
          if name.is_a?(Regexp)
            @has_regexp = true
          else
            name = name.to_s
          end
          @hash[name] = value
        end

        def fetch(name)
          @hash.fetch(name.to_s) do
            klass = nil
            if @has_regexp
              _, klass = @hash.find{ |pattern, klass|
                next unless pattern.is_a? Regexp
                name =~ pattern
              }
            end

            if klass.nil?
              if block_given?
                yield
              else
                raise KeyError, "No adapter registered for #{name} - try #{@hash.keys.join(", ")}"
              end
            else
              klass
            end
          end
        end
      end

      class << self

        def register(adapter_name)
          adapter_registry.put(adapter_name, self)
        end

        def adapter_registry
          registry_host.registry
        end

        def registry
          @registry ||= AdapterRegistry.new
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
