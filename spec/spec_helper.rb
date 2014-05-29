require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'rspec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'bibliotech')
