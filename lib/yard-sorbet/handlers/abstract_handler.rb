# typed: strict
# frozen_string_literal: true

# Handle +enums+ calls, registering enum values as constants
class YARDSorbet::Handlers::AbstractHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:abstract!), method_call(:interface!)
  namespace_only

  sig { void }
  def process
    return if namespace.has_tag?(:abstract)

    tag = YARD::Tags::Tag.new(:abstract, 'Descendants must implement the +abstract+ methods')
    namespace.add_tag(tag)
  end
end
