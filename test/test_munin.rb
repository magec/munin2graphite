require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMunin < Test::Unit::TestCase
  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    @munin = Munin::Node.new(Munin2Graphite::Config["munin_hostname"],Munin2Graphite::Config["munin_port"])
  end
  
  def test_metric_lists
    metrics = @munin.list
    assert_not_nil metrics
    assert_not_empty metrics
  end
  
  def test_nodes
    nodes = @munin.nodes
    assert_not_nil nodes
    assert_not_empty nodes
  end

  def test_value_for
    first_metric = @munin.list.first
    values = @munin.fetch first_metric
    assert_not_nil values
    assert_not_empty values.keys
  end

  def test_graph_for
    munin_graph = MuninGraph.graph_for @munin.raw_config(@munin.list.first)
    assert_equal munin_graph.class, MuninGraph
  end

  def test_graph_for
    @munin.list.each do |metric|
      munin_graph = MuninGraph.graph_for @munin.config(metric,true)[metric]

      munin_graph.config = Munin2Graphite::Config.merge("metric" => metric,"hostname" => @munin.nodes.first.split(".").first)
      munin_graph.to_graphite.save!
      assert_equal munin_graph.class, MuninGraph
    end
  end
 
end
