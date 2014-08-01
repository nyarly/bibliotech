module BiblioTech
  class CLI < Thor
    def latest
      app = App.new
      app.latest
    end
  end
end
