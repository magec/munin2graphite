#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__),"..","lib")))
require 'rubygems'
require 'munin2graphite'

if ARGV.last && File.stat(ARGV.last)
  Munin2Graphite::Config.config_file = ARGV.last
else
  Munin2Graphite::Config.config_file = File.expand_path(File.join(File.dirname(__FILE__),"..","conf","munin2graphite.conf"))
end

Thread.abort_on_exception = true 

scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
scheduler.start
scheduler.scheduler.join
