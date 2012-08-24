require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMuninGraph < Test::Unit::TestCase

  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
  end

  def test_obtain_metrics
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
    @scheduler.obtain_metrics
  end
  
  def test_obtain_graphs
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
    @scheduler.obtain_graphs
  end

  def test_obtain_graphs_when_it_cannot_connect
    Munin2Graphite::Config.config.params["test_worker1"]["munin_hostname"] = "192.168.1.1"
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
    assert_nothing_thrown { @scheduler.obtain_graphs }
  end

  def test_send_graphs
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
    @scheduler.obtain_metrics
  end

end
