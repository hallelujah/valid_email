# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valid_email/version"

Gem::Specification.new do |s|
  s.name        = "valid_email"
  s.version     = ValidEmailVersion
  s.authors     = ["Ramihajamalala Hery"]
  s.email       = ["hery@rails-royce.org"]
  s.homepage    = "https://github.com/hallelujah/valid_email"
  s.summary     = %q{ActiveModel Validation for email}
  s.description = %q{ActiveModel Validation for email}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 3.10"
  s.add_development_dependency "rake", '< 11.0'
  s.add_runtime_dependency "mail", ">= 2.6.1"
  s.add_runtime_dependency "simpleidn"
  if Gem::Version.new(RUBY_VERSION) <= Gem::Version.new('2.0')
    s.add_runtime_dependency 'mime-types', '<= 2.6.2'
  end
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
    s.add_runtime_dependency "activemodel", '< 5.0.0'
  else
    s.add_runtime_dependency "activemodel"
  end
end
