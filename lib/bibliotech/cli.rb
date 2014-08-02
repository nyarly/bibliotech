module BiblioTech
  class CLI < Thor
    desc "latest", "Outputs the latest DB dump available locally"
    def latest
      app = App.new
      app.latest
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
  end
end
