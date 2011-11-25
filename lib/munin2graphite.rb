$:.unshift(File.join(File.expand_path(File.dirname(__FILE__),"munin2graphite")))
require 'rubygems'
require 'munin-ruby'
require 'carbon'
require 'graphite'
require 'munin_graph'
require 'munin2graphite/config'
require 'munin2graphite/scheduler'
