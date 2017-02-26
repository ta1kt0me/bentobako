# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bentobako/version'

Gem::Specification.new do |spec|
  spec.name          = "bentobako"
  spec.version       = Bentobako::VERSION
  spec.authors       = ["ta1kt0me"]
  spec.email         = ["p.wadachi@gmail.com"]

  spec.summary       = %q{Setup execution enviromnet via mitamae}
  spec.description   = %q{Setup execution enviromnet via mitamae}
  spec.homepage      = %q{https://github.com/ta1kt0me/bentobako}
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock"
end
