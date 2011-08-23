require 'json'

module Graphite
  class Graph < Graphite::Base
    attr_accessor :name,:id,:allow_children,:leaf,:url

    def self.find_by_query_and_path(query,path)
      graph_type = "#{self}" == "Graphite::MyGraph" ? "mygraph" : "usergraph"
      return JSON.parse(self.get("/browser/#{graph_type}/",{:format => "treejson",:query => query,:path =>path}).body).map do |graphic_hash|
        graphic = MyGraph.new
        graphic.url            = graphic_hash["graphUrl"]
        graphic.name           = graphic_hash["id"]
        graphic.leaf           = graphic_hash["leaf"] == 1
        graphic.allow_children = graphic_hash["allowChildren"] == 1
        graphic
      end
    end


    def self.descend_to_leaf(query,path)
      result = []
      self.find_by_query_and_path(query,path).each do |graph|
        if graph.leaf 
          return graph 
        else
          result << self.descend_to_leaf(graph.name + "*",graph.name)
        end        
      end
      return result
    end

    def self.find_all_by_query(query)
      result = []
      self.find_by_query_and_path(query,"").each do |graph|        
        result << self.descend_to_leaf(graph.name + "*",graph.name)
      end
      return result.flatten
    end
  end
end
