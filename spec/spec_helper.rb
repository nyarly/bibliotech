begin
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
rescue LoadError
end
require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'bibliotech')
