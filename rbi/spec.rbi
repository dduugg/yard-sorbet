# typed: strict
extend RSpec::SharedContext
extend RSpec::Matchers
extend RSpec::Mocks::ExampleMethods

# RSpec::Core::ExampleGroup methods
def self.described_class; end
def self.it(*all_args, &block); end
