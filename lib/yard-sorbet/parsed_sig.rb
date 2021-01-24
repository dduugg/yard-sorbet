# typed: strict
# frozen_string_literal: true

# A struct that holds the parsed contents of a Sorbet type signature
class YARDSorbet::ParsedSig < T::Struct
  prop :abstract, T::Boolean, default: false
  prop :params, T::Hash[String, T::Array[String]], default: {}
  prop :return, T.nilable(T::Array[String])
end
