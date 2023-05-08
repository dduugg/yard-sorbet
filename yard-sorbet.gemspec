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
  spec.description = 'A YARD plugin that incorporates Sorbet type information'
  spec.homepage = 'https://github.com/dduugg/yard-sorbet'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'documentation_uri' => 'https://dduugg.github.io/yard-sorbet/',
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => spec.homepage,
    'wiki_uri' => "#{spec.homepage}/wiki"
  }

  spec.files = Dir['lib/**/*', 'LICENSE']

  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'redcarpet', '~> 3.6.0'
  spec.add_development_dependency 'rspec', '~> 3.12.0'
  spec.add_development_dependency 'rubocop', '~> 1.50.2'
  spec.add_development_dependency 'rubocop-packaging', '~> 0.5.2'
  spec.add_development_dependency 'rubocop-performance', '~> 1.17.1'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.22.0'
  spec.add_development_dependency 'rubocop-sorbet', '~> 0.7.0'
  spec.add_development_dependency 'simplecov-cobertura', '~> 2.1.0'
  spec.add_development_dependency 'sorbet', '~> 0.5.9204'
  spec.add_development_dependency 'tapioca', '~> 0.11.1'
  spec.add_runtime_dependency 'sorbet-runtime'
  spec.add_runtime_dependency 'yard'
end
