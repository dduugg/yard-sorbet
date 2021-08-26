# typed: strict
# frozen_string_literal: true

require_relative 'lib/yard-sorbet/version'

Gem::Specification.new do |spec|
  spec.name = 'yard-sorbet'
  spec.version = YARDSorbet::VERSION
  spec.author = 'Douglas Eichelberger'
  spec.email = 'dduugg@gmail.com'
  spec.license = 'Apache-2.0'

  spec.summary = 'Create YARD docs from Sorbet type signatures'
  spec.description = <<~DESC
    A YARD plugin that incorporates Sorbet type information
  DESC
  spec.homepage = 'https://github.com/dduugg/yard-sorbet'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'documentation_uri' => 'https://dduugg.github.io/yard-sorbet/',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'wiki_uri' => "#{spec.homepage}/wiki"
  }

  spec.files = `git ls-files -z -- lib/*`.split("\x0") + ['LICENSE']

  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'redcarpet', '~> 3.5'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.20.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.11.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4.0'
  spec.add_development_dependency 'rubocop-sorbet', '~> 0.6.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sorbet', '~> 0.5.6289'
  spec.add_runtime_dependency 'sorbet-runtime', '>= 0.5'
  spec.add_runtime_dependency 'yard', '>= 0.9'
end
