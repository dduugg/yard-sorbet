# typed: strong
# frozen_string_literal: true

# Custom YARD Handlers
# @see https://rubydoc.info/gems/yard/YARD/Handlers/Base YARD Base Handler documentation
module YARDSorbet::Handlers; end

require_relative 'handlers/enums_handler'
require_relative 'handlers/sig_handler'
require_relative 'handlers/struct_handler'
