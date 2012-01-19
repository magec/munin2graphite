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
# You should have received a copy of the GNU General putsPublic License
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
        if configline =~ /^graph_category ([\w\-_]+)$/
          return configline.split[1]
        end
      end
      raise "CategoryNotFound in #{config}"
    end

    def munin_config
      return @munin_config if @munin_config
      @munin_config = {}
      @munin_config[:workers] = []
      workers.each do |worker|
        current_config = {}
        config = @config.config_for_worker(worker)
        munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
        nodes = config["munin_nodes"] ? config["munin_nodes"].split(",") : munin.nodes
        current_config[:nodes] = {}
        nodes.each do |node|
          metrics = munin.list(node)
          current_config[:nodes][node] = { :metrics => {} }
          metrics.each do |metric|
            begin
              raw_config = munin.config(metric,true)[metric]
              category = category_from_config(raw_config)
              current_config[:nodes][node][:metrics][metric] = {
                :config => munin.config(metric)[metric],
                :raw_config => raw_config,
                :category => category
              }
            rescue Exception
              config.log.error("Error when trying to obtain graph conf. Ignored (config was #{raw_config})")
            end
          end
        end
        #       @config.log.debug(current_config.inspect)
        @munin_config[worker] = current_config
        @munin_config[:workers] << worker
        munin.disconnect
      end
#      @config.log.debug(@munin_config.inspect)
      @munin_config
    end

    def workers
      @workers ||= (@config.workers.empty? ?  ["global"] : @config.workers )
    end

    #
    # This is the loop of the metrics scheduling
    def obtain_metrics(worker = "global")
      config = @config.config_for_worker("global")
      time = Time.now
      config = @config.config_for_worker(worker)
      config.log.info("Worker #{worker}")
      metric_base = config["graphite_metric_prefix"]
      munin_config[worker][:nodes].each do |node,node_conf|
        node_name = metric_base + "." + node.split(".").first
        config.log.debug("Doing #{node_name}")
        values = {}
        config.log.debug("Asking for: #{node}")
        metric_time = Time.now
        metrics = node_conf[:metrics].keys
        config.log.debug("Metrics " + metrics.join(","))
        metrics_threads = []
        categories = {}
        metrics.each do |metric|
          metrics_threads << Thread.new do
            begin
              local_munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
              values[metric] =  local_munin.fetch metric
              local_munin.disconnect
            rescue
              @config.log.error("There was a problem when getting the metric #{metric} for #{node} , Ignored")
            end
          end
        end
        metrics_threads.each {|i| i.join;i.kill}
        config.log.debug(values.inspect)
        config.log.info("Done with: #{node} (#{Time.now - metric_time} s)")
        carbon = Carbon.new(config["carbon_hostname"],config["carbon_port"])
        string_to_send = ""
        values.each do |metric,results|
          category = node_conf[:metrics][metric][:category]
          results.each do |k,v|
            v.each do |c_metric,c_value|
              string_to_send += "#{node_name}.#{category}.#{metric}.#{c_metric} #{c_value} #{Time.now.to_i}\n".gsub("-","_")  if c_value != "U"
            end
          end
        end
        @config.log.debug(string_to_send)
        send_time = Time.now
        carbon.send(string_to_send)
        carbon.flush
        carbon.close
      end if munin_config[worker]
      @config.log.info("End getting metrics for worker #{worker}, elapsed time (#{Time.now - time}s)")
    end

    def obtain_graphs
      munin_config
      munin_config[:workers].each do |worker|
        time = Time.now
        config = @config.config_for_worker worker
        @config.log.info("Begin : Sending Graph Information to Graphite for worker #{worker}")
        Graphite::Base.set_connection(config["graphite_endpoint"])
        Graphite::Base.authenticate(config["graphite_user"],config["graphite_password"])
        munin_config[worker][:nodes].keys.each do |node|
          @config.log.info("Graphs for #{node}")
          munin_config[worker][:nodes][node][:metrics].each do |metric,value|
            @config.log.info("Configuring #{metric}")
            munin_graph = MuninGraph.graph_for value[:raw_config]
            munin_graph.config = config.merge("metric" => "#{metric}","hostname" => node.split(".").first)
            @config.log.debug("Saving graph #{metric}")
            munin_graph.to_graphite.save!
          end
        end
        config.log.info("End : Sending Graph Information to Graphite for worker #{worker}, elapsed time (#{Time.now - time}s)")
      end
    end

    def start
      @config.log.info("Scheduler started")
      obtain_graphs
      @scheduler = Rufus::Scheduler.start_new
      workers.each do |worker|
        config = @config.config_for_worker worker
        @config.log.info("Scheduling worker #{worker} every  #{config["scheduler_metrics_period"]} ")
        @scheduler.every config["scheduler_metrics_period"] do
          obtain_metrics(worker)
        end
      end
    end
  end
end
