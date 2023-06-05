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

  spec.add_runtime_dependency 'sorbet-runtime'
  spec.add_runtime_dependency 'yard'
end
