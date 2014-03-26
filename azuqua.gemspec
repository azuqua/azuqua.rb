# -*- encoding: utf-8 -*-
require File.expand_path("../lib/azuqua/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "azuqua"
  s.version      = Azuqua::VERSION
  s.date         = "2014-03-25"
  s.platform     = Gem::Platform::RUBY
  s.summary      = "The official Azuqua API client gem"
  s.description  = "An Ruby interface for interacting with the Azuqua API"
  s.authors      = ["Alec Embke"]
  s.email        = "alec@azuqua.com"
  s.files        = `git ls-files`.split("\n")
  s.homepage     = "http://developer.azuqua.com"
  s.license      = "MIT"
  s.require_path = "lib"

  s.post_install_message = "Note: This library requires openssl support"
  s.requirements << "sudo apt-get -y build-essential install openssl zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev"

  s.add_development_dependency "rspec", "~> 2.14.1"
  s.add_runtime_dependency "json", "~> 1.8.1"
end