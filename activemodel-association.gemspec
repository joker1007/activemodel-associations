# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activemodel/association/version'

Gem::Specification.new do |spec|
  spec.name          = "activemodel-association"
  spec.version       = ActiveModel::Association::VERSION
  spec.authors       = ["joker1007"]
  spec.email         = ["kakyoin.hierophant@gmail.com"]
  spec.summary       = %q{ActiveRecord Association Helper for PORO}
  spec.description   = %q{ActiveRecord Association Helper for PORO}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", "< 5"
  spec.add_runtime_dependency "activesupport", "< 5"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "tapp"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
end
