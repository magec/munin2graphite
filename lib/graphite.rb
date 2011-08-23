$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__)),"graphite")
require 'graphite/base'
require 'graphite/metric'
require 'graphite/graph'
require 'graphite/my_graph'
require 'graphite/user_graph'

