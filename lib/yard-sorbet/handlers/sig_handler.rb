# typed: strict
# frozen_string_literal: true

# A YARD Handler for Sorbet type declarations
class YARDSorbet::Handlers::SigHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:sig)
  namespace_only

  # A struct that holds the parsed contents of a Sorbet type signature
  class ParsedSig < T::Struct
    prop :abstract, T::Boolean, default: false
    prop :params, T::Hash[String, T::Array[String]], default: {}
    prop :return, T.nilable(T::Array[String])
  end

  # Skip these node types when parsing `sig` params
  PARAM_EXCLUDES = T.let(%i[array call hash].freeze, T::Array[Symbol])
  # Skip these node types when parsing `sig`s
  SIG_EXCLUDES = T.let(%i[array hash].freeze, T::Array[Symbol])

  private_constant :ParsedSig, :PARAM_EXCLUDES, :SIG_EXCLUDES

  # Swap the method definition docstring and the sig docstring.
  # Parse relevant parts of the `sig` and include them as well.
  sig { void }
  def process
    method_node = YARDSorbet::NodeUtils.get_method_node(YARDSorbet::NodeUtils.sibling_node(statement))
    docstring, directives = YARDSorbet::Directives.extract_directives(statement.docstring)
    parsed_sig = parse_sig(statement)
    enhance_tag(docstring, :abstract, parsed_sig)
    enhance_tag(docstring, :return, parsed_sig)
    if method_node.type != :command
      parsed_sig.params.each do |name, types|
        enhance_param(docstring, name, types)
      end
    end
    method_node.docstring = docstring.to_raw
    YARDSorbet::Directives.add_directives(method_node.docstring, directives)
    statement.docstring = nil
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
    return unless type_value

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
    YARDSorbet::NodeUtils.bfs_traverse(sig_node, exclude: SIG_EXCLUDES) do |n|
      if n.source == 'abstract'
        parsed.abstract = true
      elsif n.source == 'params' && !found_params
        found_params = true
        sibling = YARDSorbet::NodeUtils.sibling_node(n)
        YARDSorbet::NodeUtils.bfs_traverse(sibling, exclude: PARAM_EXCLUDES) do |p|
          if p.type == :assoc
            param_name = p.children.first.source[0...-1]
            types = YARDSorbet::SigToYARD.convert(p.children.last)
            parsed.params[param_name] = types
          end
        end
      elsif n.source == 'returns' && !found_return
        found_return = true
        parsed.return = YARDSorbet::SigToYARD.convert(YARDSorbet::NodeUtils.sibling_node(n))
      elsif n.source == 'void'
        parsed.return ||= ['void']
      end
    end
    parsed
  end
end
