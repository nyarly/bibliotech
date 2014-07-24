module BiblioTech
  class CommandRunner

    attr_reader :generator
    attr_accessor :shell

    def initialize(config)
      @config = config
      @generator = CommandGenerator.for(config.db_config)
      @shell = Caliph.new
    end

    def export(filepath)
      run decorate_for_compression(generator, filepath).export(filepath)
    end

    def import(filepath)
      run decorate_for_compression(generator, filepath).import(filepath)
    end

    #def wipe()
      #tables = system(CommandGenerator.new.fetch_tables(@config))
      #filter_tables_for_wipeable(tables)
      #system(CommandGenerator.new.wipe_tables(@config,tables))
    #end
    def run(command)
      @shell.run(command)
    end

    private
    def decorate_for_compression(generator, filepath)
      Compression.for(filepath, generator)
    end

  end
end
