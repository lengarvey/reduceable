# -*- encoding: utf-8 -*-
require File.expand_path("../lib/reduceable/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "reduceable"
  s.version     = Reduceable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Leonard Garvey']
  s.email       = ['lengarvey@gmail.com']
  s.homepage    = "http://github.com/lengarvey/reduceable"
  s.summary     = "Reduceable makes map reduce in mongo easy"
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.3.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
