require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "./lib/court-to-csv"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :clean do
  CourtToCSV::CLI.new.clear_tmp
end
