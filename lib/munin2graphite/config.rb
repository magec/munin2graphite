require 'parseconfig'
require 'logger'
module Munin2Graphite

  class Config

    class NotConfiguredException < Exception; end
    class ConfigFileNotFoundException < Exception; end
    class MalformedConfigFileException < Exception; end
    class RequiredFieldMissingException < Exception; end

    class << self

      # Returns the config for a given class
      def config_for_class(klass)
        return @config[klass.to_s.decamelize.to_sym]
      end

      def workers
        return @config.groups
      end

      attr_accessor :config

      # This method will return a config class but for a given worker, so everything will be the same as in the original class
      # but the config changes made in this worker
      def config_for_worker(worker)
        return self if worker == "global"
        cloned = self.clone
        cloned.config = @config.clone
        cloned.config.params = @config.params.merge(@config.params[worker])
        return cloned
      end

      def deconfigure!
        @config = nil
        @config_file = nil
      end

      def configured?
        return @config_file != nil
      end

      def parse_config
        begin
          @config = ParseConfig.new(@config_file)
        rescue Errno::ENOENT
          raise ConfigFileNotFoundException.new("Error, trying to open the config file #{@config_file}")
        rescue ArgumentError => exception
          raise MalformedConfigFileException.new("Malformed config file '#{@config_file}' #{exception.message}")
        rescue
          raise "Unknown error when trying to open config file '#{@config_file}'"
        end
        @config
      end

      def check_config
        fields={:carbon => [:hostname,:port],:graphite => [:endpoint,:metric_prefix,:user,:password],:scheduler => [:metrics_period,:graphs_period]}
        fields.each do |k,v|
          v.each do |inner_field|
            field = "#{k}_#{inner_field}"
            if !@config.params[field] 
              workers.each do |worker|
                raise RequiredFieldMissingException.new("Error, required field not found in config ':#{field}' for worker #{worker}") unless @config.params[worker][field]
              end
              
              raise RequiredFieldMissingException.new("Error, required field not found in config ':#{field}'") if workers.empty?
            end
          end
        end
      end
     
      def method_missing(method_name,*args)
        if !@config
          if @config_file
            parse_and_check!
          end
          raise NotConfiguredException.new("Not Configured") unless @config
        end
          
        if method_name == :"[]"
          if @config.params.has_key?(args.first.to_s)
            return @config.params[args.first.to_s]
          end
        end
        if @config.params.respond_to?method_name
          return @config.params.send(method_name,*args)
        end
        super
      end

      def log        
        shift_age  = self["log_shift_age"].to_i || 1
        shift_size = self["log_shift_size"].to_i || 100000
        @log ||= if self["log"] == "STDOUT"
                   Logger.new(STDOUT, shift_age, shift_size)
                 else
                   Logger.new(self["log"], shift_age, shift_size)
                 end
        @log.level = self["log_level"] == "DEBUG" ? Logger::DEBUG : Logger::INFO
        @log
      end

      def config_file=(config_file)
        @config_file = config_file
      end

      def config=(config)
        @config = config
        check_config
      end

      def parse_and_check!
        parse_config
        check_config
      end
    end
  end
end
