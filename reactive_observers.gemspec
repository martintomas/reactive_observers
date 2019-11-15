require_relative 'lib/reactive_observers/version'

Gem::Specification.new do |spec|
  spec.name          = "reactive_observers"
  spec.version       = ReactiveObservers::VERSION
  spec.authors       = ["martintomas"]
  spec.email         = ["tomas@jchsoft.cz"]

  spec.summary       = %q{Define dependent actions for your action records super simple way}
  spec.description   = %q{This gem adds observer pattern to your active records. Active record updates can be observer super simple and robust way which allows you to define specific observer classes or use observers as part of any class. Keep your actions at one place where It is easy to maintain and modify! }
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
