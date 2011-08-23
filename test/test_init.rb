$:.unshift(File.join(File.dirname(__FILE__) + "/../lib/"))
require 'test/unit'
require 'graphite'
require 'munin2graphite'
require 'munin'
require 'munin_graph'
require 'carbon'

TEST_CONFIG_FILE = File.join(File.dirname(__FILE__),"config.yml")
Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
Graphite::Base.set_connection(Munin2Graphite::Config[:carbon][:hostname])
Graphite::Base.authenticate(Munin2Graphite::Config[:graphite][:user],Munin2Graphite::Config[:graphite][:password])
