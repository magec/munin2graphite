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

      MANDATORY_GLOBAL_FIELDS={:carbon => [:hostname,:port],:graphite => [:endpoint,:metric_prefix,:user,:password],:scheduler => [:metrics_period,:graphs_period]}
      def check_config
        MANDATORY_GLOBAL_FIELDS.each do |k,v|

          raise RequiredFieldMissingException.new("Error, required field not found in config ':#{k}'") unless @config.params[k.to_s] && @config.params[k.to_s] != ""
          v.each do |inner_field|
            raise RequiredFieldMissingException.new("Error, required field not found in config ':#{k}:#{inner_field}'") unless @config.params[k.to_s][inner_field.to_s] && @config.params[k.to_s][inner_field.to_s] != ""
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
        
        @log ||= if self[:global][:log] == "STDOUT"
                   Logger.new(STDOUT)
                 else
                   Logger.new(self[:global][:log])
                 end
        @log.level = self[:global][:log_level] == "DEBUG" ? Logger::DEBUG : Logger::INFO
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
