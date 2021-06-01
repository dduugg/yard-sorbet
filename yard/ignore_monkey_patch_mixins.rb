# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

# The Layout/EmptyLines Cop doesn't allow multiple empty lines.
# YARD, however, requires multiple empty lines in order to detach a comment from a subsequent code object.
# Neither of these are configurable, so this custom YARD docstring parser uses a single empty line to detach a comment
#   from a code object.
# @see https://docs.rubocop.org/rubocop/cops_layout.html#layoutemptylines
# @see https://github.com/lsegal/yard/issues/484
module IgnoreMonkeyPatchMixins
  extend T::Helpers
  extend T::Sig

  requires_ancestor YARD::Handlers::Ruby::ClassHandler

  sig { params(content: YARD::Parser::Ruby::AstNode).returns(T.nilable(YARD::CodeObjects::Base)) }
  def recipient(content)
    return unless namespace.to_s.start_with?('YARDSorbet')

    super
  end
end

YARD::Handlers::Ruby::MixinHandler.prepend IgnoreMonkeyPatchMixins
