# typed: strict
# frozen_string_literal: true

module YARDSorbet
  module Handlers
    module IgnoreRbiDocstringHandler
      extend T::Sig

      sig {
        params(
          object: T.nilable(YARD::CodeObjects::Base),
          docstring: T.nilable(String),
          stmt: T.nilable(YARD::Parser::Ruby::AstNode)
        ).void
      }
      def register_docstring(object, docstring = statement.comments, stmt = statement)
        original_docstring = object&.docstring

        super

        # Ignore docstrings in RBI files.
        object.docstring = original_docstring if object && parser.file.end_with?(".rbi")
      end
    end
  end
end

YARD::Handlers::Base.prepend YARDSorbet::Handlers::IgnoreRbiDocstringHandler
