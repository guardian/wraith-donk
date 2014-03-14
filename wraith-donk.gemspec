# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'donk/version'

Gem::Specification.new do |spec|
  spec.name          = "donk"
  spec.version       = Donk::VERSION
  spec.authors       = ["DaveBlooman"]
  spec.email         = ["david.blooman@gmail.com"]
  spec.summary       = "Web viewer to start Wraith tasks"
  spec.description   = "Run Wraith tasks from the web, see status and last run"
  spec.homepage      = "http://www.responsivenews.co.uk"
  spec.license       = "Apache 2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'shotgun'

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "thin"
  spec.add_runtime_dependency "os"
  spec.add_runtime_dependency "log4r"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "wraith"
end
