require 'cadre/simplecov/vim-formatter'
require 'codeclimate-test-reporter'
SimpleCov.start do
  coverage_dir "corundum/docs/coverage"
  add_filter "./spec"
  add_filter "/vendor/bundle/"
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Cadre::SimpleCov::VimFormatter,
    CodeClimate::TestReporter::Formatter
  ]
end
