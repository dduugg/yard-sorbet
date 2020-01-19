# frozen_string_literal: true

require_relative 'lib/yard-sorbet/version'

Gem::Specification.new do |spec|
  spec.name = 'yard-sorbet'
  spec.author = 'Douglas Eichelberger'
  spec.files = []
  spec.summary = 'Create YARD docs from Sorbet type signatures'
  spec.version = YARDSorbet::VERSION
  spec.description = <<~DESC
    A YARD plugin that incorporates Sorbet type information
  DESC
  spec.email = 'dduugg@gmail.com'
  spec.homepage = 'https://github.com/dduugg/yard-sorbet'
  spec.license = 'Apache-2.0'
  spec.add_development_dependency 'codecov', '~> 0.1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.78.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'sorbet', '~> 0.5.5200'
  spec.add_runtime_dependency 'yard', '~> 0.9'
  spec.required_ruby_version = '>= 2.4.0'
end
