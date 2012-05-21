#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

require 'rake/clean'
CLOBBER.include('pkg')

RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = "-w"
end
