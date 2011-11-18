$:.unshift(File.join(File.dirname(__FILE__) + "/../lib/"))
require 'rubygems'
require 'test/unit'
require 'munin-ruby'
require 'graphite'
require 'munin2graphite'
require 'munin_graph'
require 'carbon'

TEST_CONFIG_FILE = File.join(File.dirname(__FILE__),"config.conf")
Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
Graphite::Base.set_connection(Munin2Graphite::Config["carbon_hostname"])
Graphite::Base.authenticate(Munin2Graphite::Config["graphite_user"],Munin2Graphite::Config["graphite_password"])
