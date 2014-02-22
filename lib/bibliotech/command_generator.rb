module BiblioTech
  class CommandGenerator

    class << self

    end

    def export(config, filename)
      raise NotImplementedError
    end
    def import(config, filename)
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

