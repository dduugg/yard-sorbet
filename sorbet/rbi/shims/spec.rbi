# typed: strict

class RSpec::Core::ExampleGroup
  include RSpec::SharedContext
  include RSpec::Matchers
  include RSpec::Mocks::ExampleMethods

  # RSpec::Core::ExampleGroup methods
  def self.described_class; end
  def self.it(*all_args, &block); end
end
