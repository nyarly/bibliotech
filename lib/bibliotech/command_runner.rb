module BiblioTech
  class CommandRunner

    attr_reader :generator

    def initialize(config)
      @config = config
      @generator = CommandGenerator.for(config.db_config)
    end

    def export(filepath)
      Kernel.system(generator.export(filepath))
    end

    def import(filepath)
      Kernel.system(generator.import(filepath))
    end

    #def wipe()
      #tables = system(CommandGenerator.new.fetch_tables(@config))
      #filter_tables_for_wipeable(tables)
      #system(CommandGenerator.new.wipe_tables(@config,tables))
    #end

  end
end

