# typed: true
# frozen_string_literal: true

# An abstract class
# @note this class is abstract
class MyAbstractClass
  extend T::Helpers
  extend T::Sig

  abstract!

  sig { abstract.void }
  def abstract_method; end
end
