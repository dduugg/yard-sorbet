# typed: strict
# frozen_string_literal: true

# Handle +enums+ calls, registering enum values as constants
class YARDSorbet::EnumsHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:enums)
  namespace_only

  sig { void }
  def process
    statement.traverse do |node|
      if node.type == :assign
        register YARD::CodeObjects::ConstantObject.new(namespace, node.first.source) do |obj|
          obj.docstring = node.docstring
          obj.source = node
          obj.value = node.last.source
        end
      end
    end
  end
end
