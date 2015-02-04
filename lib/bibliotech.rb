module BiblioTech
end

require 'bibliotech/config'
require 'bibliotech/command_generator'
require 'bibliotech/command_runner'
require 'bibliotech/compression'
require 'bibliotech/railtie' if defined?(Rails)
