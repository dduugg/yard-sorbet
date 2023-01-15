# typed: true
# frozen_string_literal: true

module YARDSorbet
  # Helper methods for working with `YARD` AST Nodes
  module NodeUtils
    # Command node types that can have type signatures
    ATTRIBUTE_METHODS = %i[attr attr_accessor attr_reader attr_writer].freeze
    # Skip these method contents during BFS node traversal, they can have their own nested types via `T.Proc`
    SKIP_METHOD_CONTENTS = %i[params returns].freeze
    private_constant :ATTRIBUTE_METHODS, :SKIP_METHOD_CONTENTS

    # Traverse AST nodes in breadth-first order
    # @note This will skip over some node types.
    # @yield [YARD::Parser::Ruby::AstNode]
    def self.bfs_traverse(node, &_blk)
      queue = [node]
      until queue.empty?
        n = queue.shift || raise('Node is nil')

        yield n
        n.children.each { queue.push(_1) }
        queue.pop if n.is_a?(YARD::Parser::Ruby::MethodCallNode) && SKIP_METHOD_CONTENTS.include?(n.method_name(true))
      end
    end

    def self.delete_node(node)
      node.parent.children.delete(node)
    end

    # Gets the node that a sorbet `sig` can be attached do, bypassing visisbility modifiers and the like
    def self.get_method_node(node)
      sigable_node?(node) ? node : node.jump(:def, :defs)
    end

    # Find and return the adjacent node (ascending)
    # @raise [IndexError] if the node does not have an adjacent sibling (ascending)
    def self.sibling_node(node)
      siblings = node.parent.children
      node_index = siblings.find_index { _1.equal?(node) }
      siblings.fetch(node_index + 1)
    end

    def self.sigable_node?(node)
      case node
      when YARD::Parser::Ruby::MethodDefinitionNode then true
      when YARD::Parser::Ruby::MethodCallNode then ATTRIBUTE_METHODS.include?(node.method_name(true))
      else false
      end
    end

    # @see https://github.com/lsegal/yard/blob/main/lib/yard/handlers/ruby/attribute_handler.rb
    #   YARD::Handlers::Ruby::AttributeHandler.validated_attribute_names
    def self.validated_attribute_names(attr_node)
      attr_node.parameters(false).map do |obj|
        case obj
        when YARD::Parser::Ruby::LiteralNode then obj[0][0].source
        else raise YARD::Parser::UndocumentableError, obj.source
        end
      end
    end
  end
end
