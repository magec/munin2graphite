$:.unshift(File.expand_path(File.join(File.dirname(__FILE__),"..","lib")))
require "rbconfig"
require 'rubygems'
require 'munin2graphite'

if ARGV.last && File.stat(ARGV.last)
  Munin2Graphite::Config.config_file = ARGV.last
else
  Munin2Graphite::Config.config_file = File.expand_path(File.join(File.dirname(__FILE__),"..","conf","munin2graphite.conf"))
end
Thread.abort_on_exception = true 

require "rubygems"
require 'win32/daemon'

include Win32

begin
class DemoDaemon < Daemon

  def service_main
  	begin
        @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
	@scheduler.start
	@scheduler.scheduler.join
	rescue
		Munin2Graphite::Config.log.error($!)
		end
  end 

  def service_stop
  	@scheduler.scheduler.stop
	exit 0
  end
end
   DemoDaemon.mainloop
rescue
   Munin2Graphite::Config.log.error($!);
end

