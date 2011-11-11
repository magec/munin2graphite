require 'socket'
require 'munin_graph'
#
# Author:: Jose Fernandez (@magec)
# Copyright:: Copyright (c) 2011 UOC (Universitat Oberta de Catalunya)
#
# Author:: Adam Jacob (<adam@hjksolutions.com>)
# Copyright:: Copyright (c) 2008 HJK Solutions, LLC
# License:: GNU General Public License version 2 or later
#
# This program and entire repository is free software; you can
# redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software
# Foundation; either version 2 of the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
class Munin
  
  attr_accessor :hostname
  
  def initialize(host='127.0.0.1', port=4949)
    @hostname = host
    @port = port
    new_connection
  end

  def new_connection
    @munin = TCPSocket.new(@hostname, @port)
    @munin.gets
  end
  
  # Nodes available in the node
  def nodes
    get_response("nodes") 
  end			 
  
  # Metrics available in the node
  def metrics(node = "")
    get_response("list #{node}")[0].split(" ")
  end

  def get_category(metric)
    get_response("config #{metric}").each do |configline|
        return $1 if configline =~ /graph_category (.+)/
    end
    return "other"
  end

  # Returns a MuninGraph Instance fot the given metric
  def graph_for(metric)    
    config = get_response("config #{metric}").join("\n")
    graph = MuninGraph.new(config)
  end
  
  # Returns a hash with the key and values for a given metric
  def values_for(metric)
    metrics = {}
    get_response("fetch #{metric}").each do |line|
      if line =~ /^(.+)\.value\s+(.+)$/
        field=$1
        value=$2
        metrics[field] = value 
      end
    end
    metrics
  end

  def close
    begin
      @munin.close  
    rescue IOError
    end
  
  end

private
  def get_response(cmd)
    @munin.puts(cmd)
    stop = false 
    response = Array.new
    while stop == false
      line = @munin.gets
      line.chomp! if line
      if line == '.' || line == ""
        stop = true
      else
        response << line 
        stop = true if cmd =~ /list/
      end
    end
    response
  end
  
end

