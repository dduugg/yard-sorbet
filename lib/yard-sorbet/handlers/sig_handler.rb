# typed: strict
# frozen_string_literal: true

module YARDSorbet
  module Handlers
    # A YARD Handler for Sorbet type declarations
    class SigHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      handles method_call(:sig)
      namespace_only

      # YARD types that can have docstrings attached to them
      Documentable = T.type_alias do
        T.any(
          YARD::CodeObjects::MethodObject, YARD::Parser::Ruby::MethodDefinitionNode, YARD::Parser::Ruby::MethodCallNode
        )
      end
      private_constant :Documentable

      # Swap the method definition docstring and the sig docstring.
      # Parse relevant parts of the `sig` and include them as well.
      sig { void }
      def process
        method_node = NodeUtils.get_method_node(NodeUtils.sibling_node(statement))
        case method_node
        when YARD::Parser::Ruby::MethodDefinitionNode then process_def(method_node)
        when YARD::Parser::Ruby::MethodCallNode then process_attr(method_node)
        end
      end

      sig { params(def_node: YARD::Parser::Ruby::MethodDefinitionNode).void }
      def process_def(def_node)
        separator = scope == :instance && def_node.type == :def ? '#' : '.'
        registered = YARD::Registry.at("#{namespace}#{separator}#{def_node.method_name(true)}")
        if registered
          parse_node(registered, registered.docstring)
          def_node.docstring = statement.docstring = nil
        else
          parse_node(def_node, statement.docstring)
          statement.docstring = nil
        end
      end

      sig { params(attr_node: YARD::Parser::Ruby::MethodCallNode).void }
      def process_attr(attr_node)
        # TODO: Merge with existing attr documentation (#141)
        parse_node(attr_node, statement.docstring, include_params: false)
        statement.docstring = nil
      end

      private

      sig { params(attach_to: Documentable, docstring: T.nilable(String), include_params: T::Boolean).void }
      def parse_node(attach_to, docstring, include_params: true)
        docstring_, directives = Directives.extract_directives(docstring)
        parse_sig(docstring_, include_params: include_params)
        attach_to.docstring = docstring_.to_raw
        Directives.add_directives(attach_to.docstring, directives)
      end

      sig { params(docstring: YARD::Docstring, include_params: T::Boolean).void }
      def parse_sig(docstring, include_params: true)
        NodeUtils.bfs_traverse(statement) do |node|
          case node.source
          when 'returns' then parse_return(node, docstring)
          when 'params' then include_params && parse_params(node, docstring)
          when 'void' then TagUtils.upsert_tag(docstring, 'return', TagUtils::VOID_RETURN_TYPE)
          when 'abstract' then TagUtils.upsert_tag(docstring, 'abstract')
          end
        end
      end

      sig { params(node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
      def parse_params(node, docstring)
        sibling = NodeUtils.sibling_node(node)
        sibling.dig(0, 0).each do |param|
          param_name = param.dig(0, 0)
          types = SigToYARD.convert(param.last)
          TagUtils.upsert_tag(docstring, 'param', types, param_name)
        end
      end

      sig { params(node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
      def parse_return(node, docstring)
        type = SigToYARD.convert(NodeUtils.sibling_node(node))
        TagUtils.upsert_tag(docstring, 'return', type)
      end
    end
  end
end
