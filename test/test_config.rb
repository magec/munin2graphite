require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMunin < Test::Unit::TestCase

  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    @munin = Munin.new(Munin2Graphite::Config["munin_hostname"],Munin2Graphite::Config["munin_port"])
  end
  
  def test_config
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    assert Munin2Graphite::Config.configured?
  end

  def test_config_workers
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    assert_not_empty Munin2Graphite::Config.workers
  end

  def test_worker_config
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    worker_config = Munin2Graphite::Config.config_for_worker("test_worker1")
    assert_not_equal Munin2Graphite::Config["munin_hostname"], worker_config["munin_hostname"]
    assert_not_nil worker_config.log
  end
 
end
