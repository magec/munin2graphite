require 'json'

module Graphite
  class Metric < Graphite::Base
    attr_accessor :name,:id,:allow_children,:leaf 

    def self.find_by_query(query)

      return JSON.parse(self.get("/metrics/find",{:format => "treejson",:query => query}).body).map do |metric_hash|
        metric = Metric.new
        metric.name           = metric_hash["text"]
        metric.id             = metric_hash["id"]
        metric.allow_children = metric_hash["allowChildren"] == 1
        metric.leaf           = metric_hash["leaf"] == 1
        metric
      end
    end
  end
end
