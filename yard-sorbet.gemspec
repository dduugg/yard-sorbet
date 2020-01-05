# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'yard-sorbet'
  spec.author = 'Douglas Eichelberger'
  spec.files = []
  spec.summary = 'Create YARD docs from Sorbet type signatures'
  spec.version = '0.0.0'
  spec.description = <<~DESC
    A YARD plugin that incorporates Sorbet type information
  DESC
  spec.email = 'dduugg@gmail.com'
  spec.homepage = 'https://github.com/dduugg/yard-sorbet'
  spec.license = 'Apache-2.0'
  spec.add_development_dependency 'rubocop', '0.78.0'
  spec.add_development_dependency 'sorbet', '~> 0.5.5200'
  spec.add_runtime_dependency 'yard', '~> 0.9'
  spec.required_ruby_version = '>= 2.4.0'
end
