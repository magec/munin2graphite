$:.unshift(File.expand_path(File.join(File.dirname(__FILE__),"..","lib")))
require 'rubygems'
require 'munin2graphite'
Munin2Graphite::Config.config_file = File.expand_path(File.join(File.dirname(__FILE__),"..","conf","config-solaris.yml"))
Graphite::Base.set_connection(Munin2Graphite::Config[:carbon][:hostname])
Graphite::Base.authenticate(Munin2Graphite::Config[:graphite][:user],Munin2Graphite::Config[:graphite][:password])

scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
scheduler.start
scheduler.scheduler.join
