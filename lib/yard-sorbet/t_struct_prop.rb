# typed: strict
# frozen_string_literal: true

# Used to store the details of a `T::Struct` `prop` definition
class YARDSorbet::TStructProp < T::Struct
  const :default, T.nilable(String)
  const :doc, String
  const :prop_name, String
  const :source, String
  const :types, T::Array[String]
end
