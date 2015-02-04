begin
  require 'rails'
  raise LoadError unless defined? Rails

  module BiblioTech
    class Railtie < Rails::Railtie
      #XXX Consider adding Rails options for bibliotech
      #Would probably need to be exclusive with config files
      rake_tasks do
        require 'bibliotech/rake_lib'

        BiblioTech::Tasklib.new
      end
    end
  end
rescue LoadError
end
