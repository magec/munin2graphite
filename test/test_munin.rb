require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMunin < Test::Unit::TestCase
  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    @munin = Munin.new(Munin2Graphite::Config[:munin_node][:hostname],Munin2Graphite::Config[:munin_node][:port])
  end

  def test_metric_lists
    metrics = @munin.metrics
    assert_not_nil metrics
    assert_not_empty metrics
  end

  def test_nodes
    nodes = @munin.nodes
    assert_not_nil nodes
    assert_not_empty nodes
  end

  def test_value_for
    first_metric = @munin.metrics.first    
    values = @munin.values_for first_metric
    assert_not_nil values
    assert_not_empty values.keys
  end

  def test_graph_for
    munin_graph = @munin.graph_for @munin.metrics.first
    assert_equal munin_graph.class, MuninGraph
  end

  def test_graph_for
    @munin.metrics.each do |metric|
      munin_graph = @munin.graph_for metric
      munin_graph.config = Munin2Graphite::Config.merge(:metric => metric,:hostname => @munin.nodes.first.split(".").first)
      munin_graph.to_graphite.save!
      assert_equal munin_graph.class, MuninGraph
    end
  end
 
end
