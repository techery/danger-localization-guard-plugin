# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localization_guard/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-localization_guard'
  spec.version       = LocalizationGuard::VERSION
  spec.authors       = ['Max Sysenko']
  spec.email         = ['max.s@techery.io']
  spec.description   = %q{A short description of danger-localization_guard.}
  spec.summary       = %q{A longer description of danger-localization_guard.}
  spec.homepage      = 'https://github.com/Max Sysenko/danger-localization_guard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'

  # Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'

  # Linting code and docs
  spec.add_development_dependency "rubocop", "~> 0.41"
  spec.add_development_dependency "yard", "~> 0.8"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'
end