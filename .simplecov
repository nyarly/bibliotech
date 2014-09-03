require 'cadre/simplecov/vim-formatter'
require 'simplecov-json'
require 'codeclimate-test-reporter'
formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Cadre::SimpleCov::VimFormatter,
  SimpleCov::Formatter::JSONFormatter
  ]
if !ENV["CODECLIMATE_REPO_TOKEN"].nil?
  formatters << CodeClimate::TestReporter::Formatter
end

SimpleCov.start do
  coverage_dir "corundum/docs/coverage"
  add_filter "./spec"
  add_filter "/vendor/bundle/"

  formatter SimpleCov::Formatter::MultiFormatter[*formatters]
end
