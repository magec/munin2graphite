require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestGraphite < Test::Unit::TestCase

  def test_endpoint
    assert_nothing_thrown {
      Graphite::Base.set_connection(Munin2Graphite::Config["graphite_endpoint"])
      Graphite::Base.authenticate(Munin2Graphite::Config["graphite_user"],Munin2Graphite::Config["graphite_password"])
    }
  end

  def test_different_endpoint
    endpoint_uri = URI.parse(Munin2Graphite::Config["graphite_endpoint"])
    assert_nothing_thrown {
      Graphite::Base.set_connection("http://#{endpoint_uri.host}:80")
      Graphite::Base.authenticate(Munin2Graphite::Config["graphite_user"],Munin2Graphite::Config["graphite_password"])
    }
  end

  def test_different_endpoint_with_path
    endpoint_uri = URI.parse(Munin2Graphite::Config["graphite_endpoint"])
    assert_nothing_thrown {
      Graphite::Base.set_connection("http://#{endpoint_uri.host}:80////")
      Graphite::Base.authenticate(Munin2Graphite::Config["graphite_user"],Munin2Graphite::Config["graphite_password"])
    }
  end

end
