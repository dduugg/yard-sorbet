# typed: strict
# frozen_string_literal: true

# Apllies an +@abstract+ tag to +abstract!+/+interface!+ modules (if not alerady present).
class YARDSorbet::Handlers::AbstractHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:abstract!), method_call(:interface!)
  namespace_only

  # The text accompanying the `@abstract` tag.
  # @see https://github.com/lsegal/yard/blob/main/templates/default/docstring/html/abstract.erb
  #   The `@abstract` tag template
  TAG_TEXT = 'Descendants must implement the `abstract` methods below.'

  sig { void }
  def process
    return if namespace.has_tag?(:abstract)

    tag = YARD::Tags::Tag.new(:abstract, TAG_TEXT)
    namespace.add_tag(tag)
  end
end
