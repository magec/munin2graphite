require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))
require 'rspec-mocks'

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

  def test_send_graphs
    mockSocket = mock( TCPSocket )
    @scheduler = Munin2Graphite::Scheduler.new(Munin2Graphite::Config)
    @scheduler.carbon = mockSocket
    @scheduler.obtain_metrics
  end

end
