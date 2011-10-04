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
      workers = @config.workers
      workers = ["global"] if workers.empty?
      workers.each do |worker|        
        config = @config.config_for_worker(worker)
        config.log.info("Begin getting metrics")
        metric_base = config["graphite_metric_prefix"]
        all_metrics = Array.new
        @munin  = Munin.new(config["munin_hostname"],config["munin_port"])
        nodes = config["munin_nodes"].split(",") || @munin.nodes
        @munin.close
        threads = []
        nodes.each do |node|
          threads << Thread.new do 
            node_name = metric_base + "." + node.split(".").first
            config.log.debug("Doing #{node_name}")
            values = {}
            
            
            munin  = Munin.new(config["munin_hostname"],config["munin_port"])
            config.log.debug("Asking for: #{node}")		
            metric_time = Time.now
            metrics = munin.metrics(node)
            metrics_threads = []
            categories = {}
            metrics.each do |metric|
              metrics_threads << Thread.new do
                local_munin  = Munin.new(config["munin_hostname"],config["munin_node"]["port"])
                values[metric] =  local_munin.values_for metric
                categories[metric] = local_munin.get_category(metric)
                local_munin.close
                local_munin = nil
              end
            end        
            metrics_threads.each {|i| i.join;i.kill}
            config.log.debug("Done with: #{node} (#{Time.now - metric_time} s)")	
            carbon = Carbon.new(config["carbon_hostname"],config["carbon_port"])
            string_to_send = ""
            values.each do |metric,results|          
              category = categories[metric]
              results.each do |k,v|
                if v != "U" # Undefined values are ignored
                  string_to_send += "#{node_name}.#{category}.#{metric}.#{k} #{v} #{Time.now.to_i}\n".gsub("-","_")                
                end
              end
            end
            send_time = Time.now
            carbon.send(string_to_send)
            config.log.debug("Sent data (elapsed time #{Time.now - send_time}s)")
            carbon.flush
            carbon.close
            carbon = nil 
            munin.close
            munin = nil
            nil
          end
        end
      end
      threads.each { |i| i.join }
      config.log.info("End   getting metrics, elapsed time (#{Time.now - time}s)")
    end

    ##
    # The loop of the graphics creation
    def obtain_graphs
      time = Time.now
      @config.log.info("Begin : Sending Graph Information to Graphite")
      @munin  = Munin.new(@config["munin_hostname"],@config["munin_port"])
      nodes = @config["munin_nodes"] || @munin.nodes
      nodes.each do |node|
      @config.log.info("Graphs for #{node}")
      @munin.metrics(node).each do |metric|
        @config.log.info("Configuring #{metric}")
        munin_graph = @munin.graph_for metric
        munin_graph.config = Munin2Graphite::Config.merge("metric" => "#{metric}","hostname" => node.split(".").first)
	 @config.log.debug("Saving graph #{metric}")
        munin_graph.to_graphite.save!
      end
      end
      @config.log.info("End   : Sending Graph Information to Graphite, elapsed time (#{Time.now - time}s)")
      @munin.close
    end

    def start
      @config.log.info("Scheduler started")
      @scheduler = Rufus::Scheduler.start_new
      obtain_metrics
      @scheduler.every @config["scheduler_metrics_period"] do
        obtain_metrics
      end
      obtain_graphs
    end
    
  end
end
