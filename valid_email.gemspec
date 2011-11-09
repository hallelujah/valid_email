# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valid_email/version"

Gem::Specification.new do |s|
  s.name        = "valid_email"
  s.version     = ValidEmailVersion
  s.authors     = ["Ramihajamalala Hery"]
  s.email       = ["hery@rails-royce.org"]
  s.homepage    = "http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp"
  s.summary     = %q{ActiveModel Validation for email}
  s.description = %q{ActiveModel Validation for email}

  s.rubyforge_project = "valid_email"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "mail"
  s.add_runtime_dependency "activemodel"
end
