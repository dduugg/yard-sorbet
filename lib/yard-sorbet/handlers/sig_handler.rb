# typed: strict
# frozen_string_literal: true

# A YARD Handler for Sorbet type declarations
class YARDSorbet::Handlers::SigHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:sig)
  namespace_only

  # These node types attached to sigs represent attr_* declarations
  ATTR_NODE_TYPES = T.let(%i[command fcall], T::Array[Symbol])
  private_constant :ATTR_NODE_TYPES

  # Swap the method definition docstring and the sig docstring.
  # Parse relevant parts of the `sig` and include them as well.
  sig { void }
  def process
    method_node = YARDSorbet::NodeUtils.get_method_node(YARDSorbet::NodeUtils.sibling_node(statement))
    docstring, directives = YARDSorbet::Directives.extract_directives(statement.docstring)
    parse_sig(method_node, docstring)
    method_node.docstring = docstring.to_raw
    YARDSorbet::Directives.add_directives(method_node.docstring, directives)
    statement.docstring = nil
  end

  private

  sig { params(method_node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
  def parse_sig(method_node, docstring)
    YARDSorbet::NodeUtils.bfs_traverse(statement) do |n|
      case n.source
      when 'abstract'
        YARDSorbet::TagUtils.upsert_tag(docstring, 'abstract')
      when 'params'
        parse_params(method_node, n, docstring)
      when 'returns', 'void'
        parse_return(n, docstring)
      end
    end
  end

  sig do
    params(
      method_node: YARD::Parser::Ruby::AstNode,
      node: YARD::Parser::Ruby::AstNode,
      docstring: YARD::Docstring
    ).void
  end
  def parse_params(method_node, node, docstring)
    return if ATTR_NODE_TYPES.include?(method_node.type)

    sibling = YARDSorbet::NodeUtils.sibling_node(node)
    sibling[0][0].each do |p|
      param_name = p[0][0]
      types = YARDSorbet::SigToYARD.convert(p.last)
      YARDSorbet::TagUtils.upsert_tag(docstring, 'param', types, param_name)
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
  def parse_return(node, docstring)
    type = node.source == 'void' ? ['void'] : YARDSorbet::SigToYARD.convert(YARDSorbet::NodeUtils.sibling_node(node))
    YARDSorbet::TagUtils.upsert_tag(docstring, 'return', type)
  end
end
