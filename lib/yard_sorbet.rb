# frozen_string_literal: true
# typed: strong
require 'sorbet-runtime'
require 'yard'

# top-level namespace
module YARDSorbet; end

require_relative 'yard_sorbet/sig_handler'
require_relative 'yard_sorbet/sig_to_yard'
