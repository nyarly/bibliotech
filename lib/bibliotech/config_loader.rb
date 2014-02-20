module BiblioTech
  class ConfigLoader
    require 'yaml'
    attr_reader :config

    def initialize(path)
      @config = YAML::load(File.open(path))
    end

  end
end
