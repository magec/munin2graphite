require 'net/http'

module Graphite
  class Base    


    # connection instance (shared with every instance of the class)
    def self.connection      
      @init_header ||= {}
      @@connection ||= begin
        endpoint_uri = URI.parse(@@endpoint)
        @@path = endpoint_uri.path
        Net::HTTP.new(endpoint_uri.host, endpoint_uri.port)
      end
    end

    # If the operation needs authentication you have to call this first
    def self.authenticate(user = @@user,password = @@password)
      response = self.connection.post(@@path + "account/login","nextPage=/&password=#{password}&username=#{user}")
      @@init_header =  {"Cookie" => response.get_fields('Set-Cookie').first}
    end

    def self.set_connection(endpoint,user = "",password = "")
      @@endpoint = endpoint
      @@user ||= user
      @@password ||= password
    end
    
    # Get
    def self.get(path,args)      
      self.connection.get(@@path + path + "?" + args.map { |i,j| i.to_s + "=" + j }.join("&"),@@init_header)
    end
  end
end
