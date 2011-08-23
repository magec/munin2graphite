require File.join(File.expand_path(File.dirname(__FILE__)),"../test_init")
require 'tempfile'

class TestMyGraph < Test::Unit::TestCase

  def setup
    Munin2Graphite::Config.deconfigure!
  end

  def teardown
  end

  def test_config_init_without_config_file
    Munin2Graphite::Config.config_file = "/TMP/it does exist, C'mon!"
    assert_raise(Munin2Graphite::Config::ConfigFileNotFoundException) {
      Munin2Graphite::Config.carbon
    }
  end

  def test_config_raises_exception_when_malformed
    file = Tempfile.new('foo')
    file.write("test_:::: : ::: [] of_a_malformed thing, \nthat does not confo")
    file.close
    Munin2Graphite::Config.config_file = file.path
    assert_raise(Munin2Graphite::Config::MalformedConfigFileException) {
      Munin2Graphite::Config.carbon
    }
    file.unlink
  end

  def test_config_raises_exception_when_not_configured
    assert_raise(Munin2Graphite::Config::NotConfiguredException) {
      Munin2Graphite::Config.carbon
    }
  end

  def test_config_initialization_raises_exception_when_mandatory_fields_are_not_present
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    file = Tempfile.new('foo')
    file.write(":thing:\n  :other_thing:")
    file.close
    Munin2Graphite::Config.config_file = file.path
    assert_raise(Munin2Graphite::Config::RequiredFieldMissingException){
      Munin2Graphite::Config.carbon
    }
  end

  def test_correct_initalization
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    assert_not_equal Munin2Graphite::Config[:carbon][:hostname],"","should be filled"
  end

end
