# typed: true
# frozen_string_literal: true

module YARDSorbet
  # Used to store the details of a `T::Struct` `prop` definition
  TStructProp = Struct.new(:default, :doc, :prop_name, :source, :types, keyword_init: true)
end
