require 'bibliotech/builders'

module BiblioTech
  module Builders
    class Database < Base
      def self.find_class(config)
        adapter_registry.fetch(config.adapter.to_s) do
          raise "config.adapter is #{config.adapter.inspect} - supported adapters are #{supported_adapters.join(", ")}"
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
  end
end
