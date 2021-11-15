# typed: strict
# frozen_string_literal: true

# @todo This should be unnecessary in the next YARD release
# @see https://github.com/lsegal/yard/commit/cbd40ea783f352ac64aec1623e06ac56afadbcc1
module IgnoreMonkeyPatchMixins
  requires_ancestor { YARD::Handlers::Ruby::MixinHandler }
end
