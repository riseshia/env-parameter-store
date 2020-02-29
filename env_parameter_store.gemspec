
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "env_parameter_store/version"

Gem::Specification.new do |spec|
  spec.name          = "env_parameter_store"
  spec.version       = EnvParameterStore::VERSION
  spec.authors       = ["Shia"]
  spec.email         = ["rise.shia@gmail.com"]

  spec.summary       = %q{Inject secrets to ENV.}
  spec.description   = %q{Inject secrets to ENV from AWS Systems Manager Parameter Store.}
  spec.homepage      = "https://github.com/riseshia/env_parameter_store"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"

  spec.add_dependency "aws-sdk-ssm", "~> 1.54"
end
