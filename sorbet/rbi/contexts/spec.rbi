# typed: strict
# frozen_string_literal: true

# rubocop:disable Style/MixinUsage
extend RSpec::SharedContext
extend RSpec::Matchers
extend RSpec::Mocks::ExampleMethods
# rubocop:enable Style/MixinUsage

# RSpec::Core::ExampleGroup methods
def self.described_class; end
def self.it(*all_args, &block); end
