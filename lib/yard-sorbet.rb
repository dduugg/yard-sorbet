# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'
require 'yard'

T::Configuration.default_checked_level = :tests

# top-level namespace
module YARDSorbet; end

require_relative 'yard-sorbet/directives'
require_relative 'yard-sorbet/sig_handler'
require_relative 'yard-sorbet/sig_to_yard'
require_relative 'yard-sorbet/struct_handler'
