# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'authorizator/client/version'

Gem::Specification.new do |spec|
  spec.name          = "authorizator-client"
  spec.version       = Authorizator::Client::VERSION
  spec.authors       = ["Lorenzo Tello"]
  spec.email         = ["devteam@ideas4all.com"]
  spec.summary       = "Ruby client for the ideas4all authorizator service"
  spec.description   = "Ruby client for the ideas4all authorizator service"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1.1"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_runtime_dependency "oauth2", "~> 0.9.3"
end
