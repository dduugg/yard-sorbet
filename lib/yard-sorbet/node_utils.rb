# typed: strict
# frozen_string_literal: true

# Helper methods for working with YARD AST Nodes
module YARDSorbet::NodeUtils
  extend T::Sig

  # Command node types that can have type signatures
  ATTRIBUTE_METHODS = T.let(%w[attr attr_accessor attr_reader attr_writer].freeze, T::Array[String])
  # Node types that indicate method definitions
  METHOD_NODE_TYPES = T.let(%i[def defs].freeze, T::Array[Symbol])
  # Node types that can have type signatures
  SIGABLE_NODE = T.type_alias do
    T.any(YARD::Parser::Ruby::MethodDefinitionNode, YARD::Parser::Ruby::MethodCallNode)
  end

  private_constant :ATTRIBUTE_METHODS, :METHOD_NODE_TYPES, :SIGABLE_NODE

  # @yield [YARD::Parser::Ruby::AstNode]
  sig do
    params(
      node: YARD::Parser::Ruby::AstNode,
      exclude: T::Array[Symbol],
      _blk: T.proc.params(n: YARD::Parser::Ruby::AstNode).void
    ).void
  end
  def self.bfs_traverse(node, exclude: [], &_blk)
    queue = [node]
    while !queue.empty?
      n = T.must(queue.shift)
      yield n
      n.children.each do |c|
        if !exclude.include?(c.type)
          queue.push(c)
        end
      end
    end
  end

  # Gets the node that a sorbet `sig` can be attached do, bypassing visisbility modifiers and the like
  sig { params(node: SIGABLE_NODE).returns(SIGABLE_NODE) }
  def self.get_method_node(node)
    return node if METHOD_NODE_TYPES.include?(node.type)
    return node if ATTRIBUTE_METHODS.include?(node.method_name.source)

    node.jump(:def, :defs)
  end

  # Find and return the adjacent node (ascending)
  # @raise [IndexError] if the node does not have an adjacent sibling (ascending)
  sig { params(node: YARD::Parser::Ruby::AstNode).returns(YARD::Parser::Ruby::AstNode) }
  def self.sibling_node(node)
    siblings = node.parent.children
    siblings.each_with_index.find do |sibling, i|
      if sibling == node
        return siblings.fetch(i + 1)
      end
    end
  end

  # Returns true if the given node represents a type signature.
  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Boolean) }
  def self.type_signature?(node)
    node.is_a?(YARD::Parser::Ruby::MethodCallNode) && node.method_name(true) == :sig
  end
end
