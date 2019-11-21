require_relative 'lib/reactive_observers/version'

Gem::Specification.new do |spec|
  spec.name          = "reactive_observers"
  spec.version       = ReactiveObservers::VERSION
  spec.authors       = ["martintomas"]
  spec.email         = ["tomas@jchsoft.cz"]

  spec.summary       = %q{Observe Active Record classes and records super simple way!}
  spec.description   = %q{This gem allows you to write down specialized Observer classes or make observer from every possible class/object that You can think of. Observable module is using build in Active Record hooks or database triggers which can be turned on in multiple App environment. }
  spec.homepage      = "https://github.com/martintomas/reactive_observers.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/martintomas/reactive_observers.git"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
