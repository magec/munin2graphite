require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMuninGraph < Test::Unit::TestCase

  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
  end

  def test_obtain_metrics
    @scheduler.obtain_metrics
  end

  def test_obtain_graphs
    @scheduler.obtain_graphs
  end

end
