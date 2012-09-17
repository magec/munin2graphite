# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "munin2graphite"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jose Fernandez (magec)"]
  s.date = "2012-09-17"
  s.description = "This gem will install as a daemon and can be used to connect to a graphite and a carbon backend. It will not only post the data for the metrics but also create graphs into graphite, by means of a translation from munin-node."
  s.email = "jfernandezperez@gmail.com"
  s.executables = ["munin2gdash", "munin2graphite", "munin2graphite-1r", "munin2graphite-daemon"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "bin/munin2gdash",
    "bin/munin2graphite",
    "bin/munin2graphite-1r",
    "bin/munin2graphite-daemon",
    "conf/munin2graphite.conf.example",
    "etc/munin2graphite/munin2graphite.conf.example",
    "lib/ast_node.rb",
    "lib/carbon.rb",
    "lib/graphite.rb",
    "lib/graphite/base.rb",
    "lib/graphite/graph.rb",
    "lib/graphite/metric.rb",
    "lib/graphite/my_graph.rb",
    "lib/graphite/user_graph.rb",
    "lib/munin2graphite.rb",
    "lib/munin2graphite/config.rb",
    "lib/munin2graphite/scheduler.rb",
    "lib/munin_graph.rb",
    "munin2graphite.gemspec",
    "test/munin2graphite/config_test.rb",
    "test/test_config.rb",
    "test/test_graphite.rb",
    "test/test_init.rb",
    "test/test_munin.rb",
    "test/test_munin_graph.rb",
    "test/test_my_graph.rb",
    "test/test_scheduler.rb"
  ]
  s.homepage = "http://github.com/magec/munin2graphite"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Allows to post both data and graphic info from munin to graphite (https://launchpad.net/graphite)"
  s.test_files = [
    "test/munin2graphite/config_test.rb",
    "test/test_config.rb",
    "test/test_graphite.rb",
    "test/test_init.rb",
    "test/test_munin.rb",
    "test/test_munin_graph.rb",
    "test/test_my_graph.rb",
    "test/test_scheduler.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rufus-scheduler>, ["= 2.0.10"])
      s.add_runtime_dependency(%q<daemons>, ["= 1.1.4"])
      s.add_runtime_dependency(%q<parseconfig>, [">= 0"])
      s.add_runtime_dependency(%q<munin-ruby>, ["~> 0.2.1"])
      s.add_runtime_dependency(%q<json>, ["~> 1.6.3"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
    else
      s.add_dependency(%q<rufus-scheduler>, ["= 2.0.10"])
      s.add_dependency(%q<daemons>, ["= 1.1.4"])
      s.add_dependency(%q<parseconfig>, [">= 0"])
      s.add_dependency(%q<munin-ruby>, ["~> 0.2.1"])
      s.add_dependency(%q<json>, ["~> 1.6.3"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
    end
  else
    s.add_dependency(%q<rufus-scheduler>, ["= 2.0.10"])
    s.add_dependency(%q<daemons>, ["= 1.1.4"])
    s.add_dependency(%q<parseconfig>, [">= 0"])
    s.add_dependency(%q<munin-ruby>, ["~> 0.2.1"])
    s.add_dependency(%q<json>, ["~> 1.6.3"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
  end
end

