# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{munin-ruby}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Dan Sosedoff}]
  s.date = %q{2011-11-18}
  s.description = %q{Munin Node client}
  s.email = %q{dan.sosedoff@gmail.com}
  s.homepage = %q{http://github.com/sosedoff/munin-ruby}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Ruby client library to communicate with munin-node servers}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.6"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.6"])
  end
end
