# typed: strict

class RSpec::Core::ExampleGroup
  include RSpec::SharedContext
  include RSpec::Matchers
  include RSpec::Mocks::ExampleMethods
end
