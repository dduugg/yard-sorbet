# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

# YARD erroneously attaches some `include` invocations to the root level, so we omit them instead. (The resulting
# documentation would not be helpful anyway.)
#
# @see https://github.com/lsegal/yard/issues/1386
module IgnoreMonkeyPatchMixins
  extend T::Helpers
  extend T::Sig

  sig { params(content: YARD::Parser::Ruby::AstNode).returns(T.nilable(YARD::CodeObjects::Base)) }
  def recipient(content)
    return unless namespace.to_s.start_with?('YARDSorbet')

    super
  end
end

YARD::Handlers::Ruby::MixinHandler.prepend IgnoreMonkeyPatchMixins
