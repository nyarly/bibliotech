module BiblioTech
  class ConfigLoader
    require 'yaml'
    attr_reader :config
    attr_reader :environment


    def initialize(path, environment = :development)
      @environment = environment.to_sym
      @config = YAML::load(File.open(path))[@environment]
      validate_config
    end

    private
    def validate_config
      raise "Environment #{@environment} not found in config file." unless @config.is_a?(Hash)
      raise "No adapter specified for #{@environment}" unless @config[:adapter]

    end

  end
end
