$:.unshift(File.join(File.expand_path(File.dirname(__FILE__),"munin2graphite")))
require 'munin'
require 'carbon'
require 'munin2graphite/config'
require 'munin2graphite/scheduler'
