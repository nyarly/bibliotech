require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'bibliotech')

Dir.mkdir('tmp') unless File.directory?('tmp')
File.open('tmp/test.log', "w") do |logfile|
  logfile.truncate(0)
end
