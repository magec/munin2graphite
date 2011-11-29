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
    
    def category_from_config(config)
      config.each_line do |configline|
        if configline =~ /^graph_category (\w+)$/
          return configline.split[1]
        end
      end      
    end

    #
    # This is the loop of the metrics scheduling
    def obtain_metrics
      time = Time.now
      workers = @config.workers
      workers = ["global"] if workers.empty?
      workers.each do |worker|        
        config = @config.config_for_worker(worker)
        config.log.info("Begin getting metrics for worker #{worker}")

        metric_base = config["graphite_metric_prefix"]
        all_metrics = Array.new
        munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
        nodes = config["munin_nodes"] ? config["munin_nodes"].split(",") : munin.nodes
        munin.disconnect
        @config.log.info(nodes.inspect)

        threads = []
        nodes.each do |node|
          threads << Thread.new do 
            node_name = metric_base + "." + node.split(".").first
            config.log.debug("Doing #{node_name}")
            values = {}                       
            munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
            config.log.debug("Asking for: #{node}")		
            metric_time = Time.now
            metrics = munin.list(node)
	    config.log.debug("Metrics " + metrics.join(","))
            metrics_threads = []
            categories = {}
            metrics.each do |metric|
              metrics_threads << Thread.new do
                local_munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
                values[metric] =  local_munin.fetch metric
#		config.log.debug("Values for metric #{metric}: #{values[metric].inspect}")
                category = category_from_config(local_munin.config(metric,true)[metric])
                categories[metric] = category
                local_munin.disconnect
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
                v.each do |c_metric,c_value|
                  string_to_send += "#{node_name}.#{category}.#{metric}.#{c_metric} #{c_value} #{Time.now.to_i}\n".gsub("-","_")  if c_value != "U"
                end
              end
            end
            send_time = Time.now
            carbon.send(string_to_send)
            config.log.debug("Sent data (elapsed time #{Time.now - send_time}s)")
            carbon.flush
            carbon.close
            carbon = nil 
            munin.disconnect
            munin = nil
            nil
          end
        end
        threads.each { |i| i.join }
      end
      @config.log.info("End   getting metrics, elapsed time (#{Time.now - time}s)")
    end

    ##
    # The loop of the graphics creation
    def obtain_graphs

      workers = @config.workers
      workers = ["global"] if workers.empty?

      workers.each do |worker|
        time = Time.now 
        config = @config.config_for_worker worker
        config.log.info("Begin : Sending Graph Information to Graphite for worker #{worker}")         
        munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
        nodes = config["munin_nodes"] ? config["munin_nodes"].split(",") : munin.nodes
        nodes.each do |node|
          config.log.info("Graphs for #{node}")
          munin.list(node).each do |metric|
            config.log.info("Configuring #{metric}")
            Graphite::Base.set_connection(config["carbon_hostname"])
            Graphite::Base.authenticate(config["graphite_user"],config["graphite_password"])
            munin_graph = MuninGraph.graph_for munin.config(metric,true)[metric]
            
            munin_graph.config = config.merge("metric" => "#{metric}","hostname" => node.split(".").first)
            config.log.debug("Saving graph #{metric}")
            munin_graph.to_graphite.save!
          end
        end
        config.log.info("End   : Sending Graph Information to Graphite for worker #{worker}, elapsed time (#{Time.now - time}s)")
        munin.disconnect
      end

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
