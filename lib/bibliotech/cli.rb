require 'thor'
require 'bibliotech/application'

module BiblioTech
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "latest", "Outputs the latest DB dump available locally"
    def latest
      app = App.new(:log => { :target => "/dev/null" })
      puts app.latest
    end

    desc "dump FILENAME", "Create a new database dump into FILE"
    def dump(file)
      app = App.new
      app.export(:backups => { :filename => file })
    end

    desc "load FILENAME", "Load a database file from FILE"
    def load(file)
      app = App.new
      app.import(:backups => { :filename => file })
    end

    desc "backup", "Create a database backup if needed"
    def backup()
      app = App.new
      app.create_backup
    end

    desc "config", "Dumps the configuration as parsed"
    def config
      require 'yaml'
      app = App.new
      puts "Loading from: #{app.valise.to_s}"
      puts YAML::dump(app.config.hash)
    end
  end
end
