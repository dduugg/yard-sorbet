# frozen_string_literal: true

# A YARD Handler for Sorbet type declarations
class YARDSorbet::SigHandler < YARD::Handlers::Ruby::Base
  extend T::Sig
  handles :class, :module, :singleton_class?

  sig { returns(String).checked(:never) }
  def process
    # Find the list of declarations inside the class
    class_def = statement.children.find { |c| c.type == :list }
    class_contents = class_def.children

    class_contents.each_with_index do |child, i|
      next unless type_signature?(child)

      next_statement = class_contents[i + 1]
      if %i[def defs command].include?(next_statement&.type) && !next_statement.docstring
        # Swap the method definition docstring and the sig docstring.
        # Parse relevant parts of the `sig` and include them as well.
        parser = YARD::DocstringParser.new.parse(child.docstring)
        # Directives are already parsed at this point, and there doesn't
        # seem to be an API to tweeze them from one node to another without
        # managing YARD internal state. Instead, we just extract them from
        # the raw text and re-attach them.
        directives = parser.raw_text&.split("\n")&.select do |line|
          line.start_with?('@!')
        end || []
        docstring = parser.to_docstring
        parsed_sig = parse_sig(child)
        enhance_tag(docstring, :abstract, parsed_sig)
        enhance_tag(docstring, :return, parsed_sig)
        if next_statement.type != :command
          parsed_sig[:params]&.each do |name, types|
            enhance_param(docstring, name, types)
          end
        end
        next_statement.docstring = docstring.to_raw
        directives.each do |directive|
          next_statement.docstring.concat("\n#{directive}")
        end
        child.docstring = nil
      end
    end
  end

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

  private def enhance_tag(docstring, type, parsed_sig)
    return if !parsed_sig[type]

    tag = docstring.tags.find { |t| t.tag_name == type.to_s }
    if tag
      docstring.delete_tags(type)
    else
      tag = YARD::Tags::Tag.new(type, '')
    end
    if parsed_sig[type].is_a?(Array)
      tag.types = parsed_sig[type]
    end
    docstring.add_tag(tag)
  end

  private def parse_sig(sig_node)
    parsed = {}
    parsed[:abstract] = false
    parsed[:params] = {}
    found_params = T.let(false, T::Boolean)
    found_return = T.let(false, T::Boolean)
    bfs_traverse(sig_node, exclude: %i[array hash]) do |n|
      if n.source == 'abstract'
        parsed[:abstract] = true
      elsif n.source == 'params' && !found_params
        found_params = true
        sibling = T.must(sibling_node(n))
        bfs_traverse(sibling, exclude: %i[array call hash]) do |p|
          if p.type == :assoc
            param_name = p.children.first.source[0...-1]
            types = YARDSorbet::SigToYARD.convert(p.children.last)
            parsed[:params][param_name] = types
          end
        end
      elsif n.source == 'returns' && !found_return
        found_return = true
        parsed[:return] = YARDSorbet::SigToYARD.convert(T.must(sibling_node(n)))
      elsif n.source == 'void'
        parsed[:return] ||= ['void']
      end
    end
    parsed
  end

  # Returns true if the given node is part of a type signature.
  private def type_signature?(node)
    loop do
      return false if node.nil?
      return false unless %i[call vcall fcall].include?(node.type)
      return true if T.unsafe(node).method_name(true) == :sig

      node = node.children.first
    end
  end

  private def sibling_node(node)
    found_sibling = T.let(false, T::Boolean)
    node.parent.children.each do |n|
      if found_sibling
        return n
      end

      if n == node
        found_sibling = true
      end
    end
    nil
  end

  # @yield [YARD::Parser::Ruby::AstNode]
  private def bfs_traverse(node, exclude: [])
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
