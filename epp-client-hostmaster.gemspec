# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epp-client'

Gem::Specification.new do |gem|
  gem.name          = "epp-client-hostmaster"
  gem.version       = EPPClient::Hostmaster::VERSION
  gem.authors       = ["Yuriy Kolodovskyy"]
  gem.email         = %w{kolodovskyy@ukrindex.com}
  gem.description   = %q{Hostmaster.UA EPP client library}
  gem.summary       = %q{Hostmaster.UA EPP client library}
  gem.homepage      = "https://github.com/kolodovskyy/epp-client-hostmaster"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w{lib}

  gem.add_development_dependency "bundler"
  gem.add_dependency('epp-client-base', '~> 0.11.0')
  gem.add_dependency('builder', '~> 3.1.4')
end
