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


module MyInterface
  extend T::Helpers
  extend T::Sig

  interface!
  sig { abstract.returns(T::Boolean) }
  def ibool; end
end


# @abstract Existing abstract tag
module MyTaggedAbstractModule
  extend T::Helpers
  extend T::Sig

  abstract!
  sig { abstract.returns(T::Boolean) }
  def ibool; end
end
