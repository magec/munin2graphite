require 'json'

module Graphite
  class MyGraph < Graph

    def save!
      MyGraph.get("/composer/mygraph/",:action => "save", :graphName => name,:url => url.gsub("&","%26"))
      Munin2Graphite::Config.log.debug("Saving: #{name} ") 
#      Munin2Graphite::Config.log.debug("   url: #{url}  ") 

    end

    def delete!
      MyGraph.get("/composer/mygraph/",:action => "delete", :graphName => name,:url => url.gsub("&","%26"))
    end

    # Returns a graph by name
    def self.find_by_name(name)
      MyGraph.find_by_query_and_path(name,name.split(".").first).first
    end
    
  end
end
