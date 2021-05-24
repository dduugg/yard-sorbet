# typed: strict
# frozen_string_literal: true

# Handles all +enums+ calls, registering them as constants
class YARDSorbet::EnumsHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:enums)
  namespace_only

  sig { void }
  def process
  end
end