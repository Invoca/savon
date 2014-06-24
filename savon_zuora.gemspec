# -*- encoding : utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

require "savon_zuora/version"

Gem::Specification.new do |s|
  s.name        = "savon_zuora"
  s.version     = SavonZuora::Version
  s.authors     = "Daniel Harrington"
  s.email       = "me@rubiii.com"
  s.homepage    = "http://savonrb.com"
  s.summary     = "Heavy metal Ruby SOAP client"
  s.description = "Ruby's heavy metal SOAP client"

  s.rubyforge_project = s.name

  s.add_dependency "builder",     ">= 2.1.2"
  s.add_dependency "nori_savon",  "1.1.5"
  s.add_dependency "httpi",       "~> 2.0.2"
  # s.add_dependency "wasabi",      "~> 2.1"
  s.add_dependency "wasabi",      "~> 3.0.0"
  s.add_dependency "akami",       "~> 1.0"
  s.add_dependency "gyoku",       ">= 0.4.0"
  s.add_dependency "nokogiri",    ">= 1.4.0"

  s.add_development_dependency "rake",    "~> 0.8.7"
  s.add_development_dependency "rspec",   "~> 2.5.0"
  s.add_development_dependency "mocha",   "~> 0.9.8"
  s.add_development_dependency "timecop", "~> 0.3.5"

  s.add_development_dependency "autotest"
  s.add_development_dependency "ZenTest", "= 4.5.0"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
