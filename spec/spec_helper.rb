require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  if ENV['RCOV']
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  end
  SimpleCov.start do
    add_group 'Gem', 'lib'
    add_filter "spec"
  end
end

require 'livefyre'
Livefyre.config = {:host => "foo.bar", :key => "x", :system_token => "x"}

RSpec.configure do |config|
end