# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'custom_audience/version'

Gem::Specification.new do |spec|
  spec.name          = "custom_audience"
  spec.version       = CustomAudience::VERSION
  spec.authors       = ["Jon Moses"]
  spec.email         = ["jon@burningbush.us"]
  spec.description   = %q{Easy FB custom audience creation}
  spec.summary       = %q{Because it's easy}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "koala", "~> 1.6.0"
  spec.add_dependency 'activesupport', '~> 3'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "rake"
end
