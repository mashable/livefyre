#!/usr/bin/env rake
require "bundler/gem_tasks"
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new('spec')
rescue LoadError => e
  # Pass
end

task :default => :spec