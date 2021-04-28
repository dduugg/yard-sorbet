# typed: strict
# frozen_string_literal: true

# A YARD Handler for Sorbet type declarations
class YARDSorbet::SigHandler < YARD::Handlers::Ruby::Base
  extend T::Sig
  handles :class, :module, :singleton_class?

  # A struct that holds the parsed contents of a Sorbet type signature
  class ParsedSig < T::Struct
    prop :abstract, T::Boolean, default: false
    prop :params, T::Hash[String, T::Array[String]], default: {}
    prop :return, T.nilable(T::Array[String])
  end

  PARAM_EXCLUDES = T.let(%i[array call hash].freeze, T::Array[Symbol])
  PROCESSABLE_NODES = T.let(%i[def defs command].freeze, T::Array[Symbol])
  SIG_EXCLUDES = T.let(%i[array hash].freeze, T::Array[Symbol])
  SIG_NODE_TYPES = T.let(%i[call fcall vcall].freeze, T::Array[Symbol])

  private_constant :ParsedSig, :PARAM_EXCLUDES, :PROCESSABLE_NODES, :SIG_EXCLUDES, :SIG_NODE_TYPES

  sig { void }
  def process
    # Find the list of declarations inside the class
    class_def = statement.children.find { |c| c.type == :list }
    class_contents = class_def.children

    process_class_contents(class_contents)
  end

  sig { params(class_contents: T::Array[YARD::Parser::Ruby::MethodCallNode]).void }
  private def process_class_contents(class_contents)
    class_contents.each_with_index do |child, i|
      if child.type == :sclass && child.children.size == 2 && child.children[1].type == :list
        singleton_class_contents = child.children[1]
        process_class_contents(singleton_class_contents)
      end
      next unless type_signature?(child)

      next_statement = class_contents[i + 1]
      next unless processable_method?(next_statement)

      process_method_definition(T.must(next_statement), child)
    end
  end

  sig { params(next_statement: T.nilable(YARD::Parser::Ruby::AstNode)).returns(T::Boolean) }
  private def processable_method?(next_statement)
    PROCESSABLE_NODES.include?(next_statement&.type)
  end

  sig do
    params(
      method_node: YARD::Parser::Ruby::AstNode,
      sig_node: YARD::Parser::Ruby::MethodCallNode
    ).void
  end
  private def process_method_definition(method_node, sig_node)
    # Swap the method definition docstring and the sig docstring.
    # Parse relevant parts of the `sig` and include them as well.
    docstring, directives = YARDSorbet::Directives.extract_directives(sig_node.docstring)
    parsed_sig = parse_sig(sig_node)
    enhance_tag(docstring, :abstract, parsed_sig)
    enhance_tag(docstring, :return, parsed_sig)
    if method_node.type != :command
      parsed_sig.params.each do |name, types|
        enhance_param(docstring, name, types)
      end
    end
    method_node.docstring = docstring.to_raw
    YARDSorbet::Directives.add_directives(method_node.docstring, directives)
    sig_node.docstring = nil
  end

  sig { params(docstring: YARD::Docstring, name: String, types: T::Array[String]).void }
  private def enhance_param(docstring, name, types)
    tag = docstring.tags.find { |t| t.tag_name == 'param' && t.name == name }
    if tag
      docstring.delete_tag_if { |t| t == tag }
      tag.types = types
    else
      tag = YARD::Tags::Tag.new(:param, '', types, name)
    end
    docstring.add_tag(tag)
  end

  sig { params(docstring: YARD::Docstring, type: Symbol, parsed_sig: ParsedSig).void }
  private def enhance_tag(docstring, type, parsed_sig)
    type_value = parsed_sig.public_send(type)
    return if !type_value

    tag = docstring.tags.find { |t| t.tag_name == type.to_s }
    if tag
      docstring.delete_tags(type)
    else
      tag = YARD::Tags::Tag.new(type, '')
    end
    if type_value.is_a?(Array)
      tag.types = type_value
    end
    docstring.add_tag(tag)
  end

  sig { params(sig_node: YARD::Parser::Ruby::MethodCallNode).returns(ParsedSig) }
  private def parse_sig(sig_node)
    parsed = ParsedSig.new
    found_params = T.let(false, T::Boolean)
    found_return = T.let(false, T::Boolean)
    bfs_traverse(sig_node, exclude: SIG_EXCLUDES) do |n|
      if n.source == 'abstract'
        parsed.abstract = true
      elsif n.source == 'params' && !found_params
        found_params = true
        sibling = sibling_node(n)
        bfs_traverse(sibling, exclude: PARAM_EXCLUDES) do |p|
          if p.type == :assoc
            param_name = p.children.first.source[0...-1]
            types = YARDSorbet::SigToYARD.convert(p.children.last)
            parsed.params[param_name] = types
          end
        end
      elsif n.source == 'returns' && !found_return
        found_return = true
        parsed.return = YARDSorbet::SigToYARD.convert(sibling_node(n))
      elsif n.source == 'void'
        parsed.return ||= ['void']
      end
    end
    parsed
  end

  # Returns true if the given node is part of a type signature.
  sig { params(node: T.nilable(YARD::Parser::Ruby::AstNode)).returns(T::Boolean) }
  private def type_signature?(node)
    loop do
      return false if node.nil?
      return false unless SIG_NODE_TYPES.include?(node.type)
      return true if T.unsafe(node).method_name(true) == :sig

      node = T.let(node.children.first, T.nilable(YARD::Parser::Ruby::AstNode))
    end
  end

  # Find and return the adjacent node (ascending)
  # @raise [IndexError] if the node does not have an adjacent sibling (ascending)
  sig { params(node: YARD::Parser::Ruby::AstNode).returns(YARD::Parser::Ruby::AstNode) }
  private def sibling_node(node)
    siblings = node.parent.children
    siblings.each_with_index.find do |sibling, i|
      if sibling == node
        return siblings.fetch(i + 1)
      end
    end
  end

  # @yield [YARD::Parser::Ruby::AstNode]
  sig do
    params(
      node: YARD::Parser::Ruby::AstNode,
      exclude: T::Array[Symbol],
      _blk: T.proc.params(n: YARD::Parser::Ruby::AstNode).void
    ).void
  end
  private def bfs_traverse(node, exclude: [], &_blk)
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
end
