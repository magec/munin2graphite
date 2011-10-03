$:.unshift(File.join(File.dirname(__FILE__) + "/../lib/"))
require 'test/unit'
require 'graphite'

class TestMyGraph < Test::Unit::TestCase

  def setup
    Graphite::Base.authenticate(TEST_USER,TEST_PASSWORD)
    @graphic = Graphite::MyGraph.new
    @graphic.url = "http://graphite.uoc.es/composer/../render/?width=1371&height=707&_salt=1312965749.741&target=alias(scale(derivative(campus.frontends.linux.aleia.apache.apache_volume.volume80)%2C0.016666666666666666)%2C%22Bytes%20por%20segundo%22)&title=Bytes%20transmitidos"
    @graphic.name = "Apache.Transferencia"
    @graphic.save!
  end
  
  def teardown    
    Graphite::MyGraph.find_all_by_query("*").each do |graph|
      puts graph.inspect
      graph.delete!
    end
  end

  def test_find_by_query_and_path_before_authenticate
    assert_equal Graphite::MyGraph.find_by_query_and_path("*","Apache").count, 1
  end

  def test_find_by_name
    assert_equal Graphite::MyGraph.find_by_name("Apache.Transferencia").name , "Apache.Transferencia"
  end

end
