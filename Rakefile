# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "munin2graphite"
  gem.homepage = "http://github.com/magec/munin2graphite"
  gem.license = "MIT"
  gem.summary = %Q{Allows to post both data and graphic info from munin to gtaphite (https://launchpad.net/graphite)}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "jfernandezperez@gmail.com"
  gem.authors = ["Jose Fernandez (magec)"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
