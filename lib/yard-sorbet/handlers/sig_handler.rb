# typed: strict
# frozen_string_literal: true

module YARDSorbet
  module Handlers
    # A YARD Handler for Sorbet type declarations
    class SigHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      handles method_call(:sig)
      namespace_only

      # Swap the method definition docstring and the sig docstring.
      # Parse relevant parts of the `sig` and include them as well.
      def process
        method_node = NodeUtils.get_method_node(NodeUtils.sibling_node(statement))
        case method_node
        when YARD::Parser::Ruby::MethodDefinitionNode then process_def(method_node)
        when YARD::Parser::Ruby::MethodCallNode then process_attr(method_node)
        end
        statement.docstring = nil
      end

      private

      def process_def(def_node)
        separator = scope == :instance && def_node.type == :def ? '#' : '.'
        registered = YARD::Registry.at("#{namespace}#{separator}#{def_node.method_name(true)}")
        if registered
          parse_node(registered, registered.docstring)
          # Since we're probably in an RBI file, delete the def node, which could otherwise erroneously override the
          # visibility setting
          NodeUtils.delete_node(def_node)
        else
          parse_node(def_node, statement.docstring)
        end
      end

      def process_attr(attr_node)
        return if merged_into_attr?(attr_node)

        parse_node(attr_node, statement.docstring, include_params: false)
      end

      # An attr* sig can be merged into a previous attr* docstring if it is the only parameter passed to the attr*
      # declaration. This is to avoid needing to rewrite the source code to separate merged and unmerged attr*
      # declarations.
      def merged_into_attr?(attr_node)
        names = NodeUtils.validated_attribute_names(attr_node)
        return false if names.size != 1

        attrs = namespace.attributes[scope][names[0]]
        return false if attrs.nil? || attrs.empty?

        document_attr_methods(attrs.values.compact)
        attr_node.docstring = nil
        true
      end

      def document_attr_methods(method_objects)
        method_objects.each { parse_node(_1, _1.docstring, include_params: false) }
      end

      def parse_node(attach_to, docstring, include_params: true)
        existing_docstring = docstring.is_a?(YARD::Docstring)
        docstring, directives = Directives.extract_directives(docstring) unless existing_docstring
        parse_sig(docstring, include_params: include_params)
        attach_to.docstring = docstring.to_raw
        Directives.add_directives(attach_to.docstring, directives) unless existing_docstring
      end

      def parse_sig(docstring, include_params: true)
        NodeUtils.bfs_traverse(statement) do |node|
          case node.source
          when 'returns' then parse_return(node, docstring)
          when 'params' then parse_params(node, docstring) if include_params
          when 'void' then TagUtils.upsert_tag(docstring, 'return', TagUtils::VOID_RETURN_TYPE)
          when 'abstract' then TagUtils.upsert_tag(docstring, 'abstract')
          end
        end
      end

      def parse_params(node, docstring)
        sibling = NodeUtils.sibling_node(node)
        sibling.dig(0, 0).each do |param|
          param_name = param.dig(0, 0)
          types = SigToYARD.convert(param.last)
          TagUtils.upsert_tag(docstring, 'param', types, param_name)
        end
      end

      def parse_return(node, docstring)
        type = SigToYARD.convert(NodeUtils.sibling_node(node))
        TagUtils.upsert_tag(docstring, 'return', type)
      end
    end
  end
end
