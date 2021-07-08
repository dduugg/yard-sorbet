# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

# Removes docstrings that consist solely of magic comments
class MagicCommentHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  # File header regexp that matches magic comments
  FILE_HEADER = T.let(/\Atyped: [[:alpha:]]+\nfrozen_string_literal: [[:alpha:]]+/.freeze, Regexp)

  handles :class, :module
  namespace_only

  sig { void }
  def process
    return unless statement.docstring&.match?(FILE_HEADER)

    statement.docstring = nil
  end
end
