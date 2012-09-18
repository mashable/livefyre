#!/usr/bin/env rake
require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new('spec')
rescue LoadError
  # Pass
end

task :doc do
  sh %{yard --plugin yard-tomdoc -o doc}
end