#
# Author:: Jose Fernandez (@magec)
# Copyright:: Copyright (c) 2011 UOC (Universitat Oberta de Catalunya)
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
  require 'rufus/scheduler'
module Munin2Graphite
  ##
  # This class holds the main scheduler of the system, it will perform the applicacion loops
  class Scheduler

    attr_accessor :scheduler

    def initialize(config)
      @config = config
    end
    
    #
    # This is the loop of the metrics scheduling
    def obtain_metrics
      time = Time.now
      @config.log.info("Begin getting metrics")
      metric_base = @config[:graphite][:metric_prefix]
      all_metrics = Array.new
      @munin  = Munin.new(@config[:munin_node][:hostname],@config[:munin_node][:port])
      @munin.nodes.each do |node|
        node_name = metric_base + "." + node.split(".").first
        @config.log.debug("Doing #{node_name}")
        values = {}

        @munin.metrics.each do |metric|
          values[metric] =  @munin.values_for metric
        end        

        values.each do |metric,results|          
          category = @munin.get_category(metric)
          results.each do |k,v|
 	    carbon = Carbon.new(@config[:carbon][:hostname],@config[:carbon][:port])
            string_to_send="#{node_name}.#{category}.#{metric}.#{k} #{v} #{Time.now.to_i}".gsub("-","_")
            @config.log.debug("Sending #{string_to_send}")
            carbon.send(string_to_send)
            carbon.close
 	    carbon = nil 
          end
        end
      end
      @config.log.info("End   getting metrics, elapsed time (#{Time.now - time}s)")
      @munin.close
    end

    ##
    # The loop of the graphics creation
    def obtain_graphs
      time = Time.now
      @config.log.info("Begin : Sending Graph Information to Graphite")
      @munin  = Munin.new(@config[:munin_node][:hostname],@config[:munin_node][:port])
      @munin.metrics.each do |metric|
        munin_graph = @munin.graph_for metric
        munin_graph.config = Munin2Graphite::Config.merge(:metric => metric,:hostname => @munin.nodes.first.split(".").first)
        munin_graph.to_graphite.save!
      end
      @config.log.info("End   : Sending Graph Information to Graphite, elapsed time (#{Time.now - time}s)")
      @munin.close
    end

    def start
      @config.log.info("Scheduler started")
      @scheduler = Rufus::Scheduler.start_new
obtain_metrics
      @scheduler.every @config[:scheduler][:metrics_period] do
        obtain_metrics
      end
      obtain_graphs
    end
    
  end
end
