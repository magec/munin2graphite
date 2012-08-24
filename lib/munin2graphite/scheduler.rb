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
require 'thread'
module Munin2Graphite
  ##
  # This class holds the main scheduler of the system, it will perform the applicacion loops
  class Scheduler

    attr_accessor :scheduler

    def initialize(config)
      @config = config
    end

    def carbon=(socket)
      @carbon = Carbon.new(socket)
    end

    def category_from_config(config)
      config.each_line do |configline|
        if configline =~ /^graph_category ([\w\-_\.]+)$/
          return configline.split[1]
        end
      end
      raise "CategoryNotFound in #{config}"
    end

    def munin_config(reload = false)
      return @munin_config if @munin_config && !reload
      @munin_config = {}
      @config.log.info("Obtaining metrics configuration")
      @munin_config[:workers] = []
      semaphore = Mutex.new
      threads = []
      workers.each do |worker|
        threads << Thread.new do 
          current_config = {}
          config = @config.config_for_worker(worker)
          munin_worker  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
          nodes = config["munin_nodes"] ? config["munin_nodes"].split(",") : munin_worker.nodes
          current_config[:nodes] = {}
          semaphore_nodes = Mutex.new
          threads_nodes = []
          nodes.each do |node|
            threads_nodes << Thread.new do
              munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
              metrics = munin.list(node)
              config.log.info("Config for node #{worker}::#{node}")
              semaphore_nodes.synchronize do 
                current_config[:nodes][node] = { :metrics => {} }
              end
              metrics.each do |metric|
                begin
                  raw_config = munin.config(metric,true)[metric]
                  category = category_from_config(raw_config)
                  semaphore_nodes.synchronize do 
                    current_config[:nodes][node][:metrics][metric] = {
                      :config => munin.config(metric)[metric],
                      :raw_config => raw_config,
                      :category => category
                    }
                  end
                rescue Exception
                  config.log.error("Error when trying to obtain graph conf for #{worker}::#{node}::#{metric} Ignored")
                end
              end
            end
          end
          threads_nodes.each { |i| i.join }
          #       @config.log.debug(current_config.inspect)
          semaphore.synchronize do 
            @munin_config[worker] = current_config
            @munin_config[:workers] << worker
          end
          munin_worker.disconnect
          config.log.info("Config for #{worker} obtained")
        end
      end
      threads.each { |i| i.join }
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
      
      munin_config[worker][:nodes].each do |node,node_info|
        node_name = metric_base + "." + node.split(".").first
        config.log.debug("Doing #{node_name}")
        values = {}
        config.log.debug("Asking for: #{node}")
        metric_time = Time.now
        metrics = node_info[:metrics].keys
        config.log.debug("Metrics " + metrics.join(","))
        metrics_threads = []
        categories = {}
        metrics.each do |metric|
          metrics_threads << Thread.new do
            begin
              local_munin  = Munin::Node.new(config["munin_hostname"],config["munin_port"])
              values[metric] =  local_munin.fetch metric
              local_munin.disconnect
            rescue Exception => e
              @config.log.error("There was a problem when getting the metric #{metric} for #{node} , Ignored")
              @config.log.error(e.message)
              @config.log.error(e.backtrace.inspect)
            end
          end
        end
        metrics_threads.each {|i| i.join}
        config.log.debug(values.inspect)
        config.log.info("Done with: #{node} (#{Time.now - metric_time} s)")
        carbon = @carbon || Carbon.new(config["carbon_hostname"],config["carbon_port"])
        string_to_send = ""
        values.each do |metric,results|          
          category = node_info[:metrics][metric][:category] 
          results.each do |k,v|
            v.each do |c_metric,c_value|
              name = "#{node_name}.#{category}.#{metric}.#{c_metric}".gsub("-","_")
              string_to_send += "#{name} #{c_value} #{Time.now.to_i}\n" if c_value != "U"
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

    def metric_loop(worker)
      config = @config.config_for_worker worker        
      retries = 3
      begin
        obtain_metrics(worker)
      rescue => e
        config.log.error("Exception found: (#{e.to_s})")
        e.backtrace.each { |line| config.log.error(line) }
        sleep 1
        retries -= 1
        config.log.error("Retrying")
        retry unless retries < 0
        config.log.error("Exitting, exception not solved")
        exit(1)
      end    
    end

    def start
      @config.log.info("Scheduler started")
      obtain_graphs
      @scheduler = Rufus::Scheduler.start_new
      workers.each do |worker|        
        config = @config.config_for_worker worker        
        config.log.info("Scheduling worker #{worker} every  #{config["scheduler_metrics_period"]} ")
        metric_loop(worker)
        @scheduler.every config["scheduler_metrics_period"] do
          metric_loop(worker)
        end
      end      
    end
  end
end
