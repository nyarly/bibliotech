module BiblioTech
  class Config
    require 'yaml'
    attr_accessor :db_config
    attr_accessor :environment


    def self.load(path, environment = :development)
      config = self.new
      config.environment = environment.to_sym
      config.db_config = YAML::load(File.open(path))[config.environment]
      config.validate_db_config
      config
    end

    def validate_db_config
      raise "Environment #{environment} not found in config file." unless db_config.is_a?(Hash)
      raise "No adapter specified for #{environment}" unless db_config[:adapter]
    end

  end
end
