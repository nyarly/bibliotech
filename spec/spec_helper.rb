require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'bibliotech')

File.open('tmp/test.log', "w") do |logfile|
  logfile.truncate(0)
end
