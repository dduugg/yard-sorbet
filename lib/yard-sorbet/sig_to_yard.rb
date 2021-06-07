# typed: strict
# frozen_string_literal: true

# Translate `sig` type syntax to `YARD` type syntax.
module YARDSorbet::SigToYARD
  extend T::Sig

  # Ruby 2.5 parsed call nodes slightly differently
  IS_LEGACY_RUBY_VERSION = T.let(RUBY_VERSION.start_with?('2.5.'), T::Boolean)
  private_constant :IS_LEGACY_RUBY_VERSION

  # @see https://yardoc.org/types.html
  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  def self.convert(node)
    types = convert_type(node)
    # scrub newlines, as they break the YARD parser
    types.map { |type| type.gsub(/\n\s*/, ' ') }
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.convert_type(node)
    case node.type
    when :aref then handle_aref(node)
    when :arg_paren then handle_arg_paren(node)
    when :array then handle_array(node)
    when :call then handle_call(node)
    when :const_path_ref, :const then handle_const(node)
    # Fixed hashes as return values are unsupported:
    # https://github.com/lsegal/yard/issues/425
    #
    # Hash key params can be individually documented with `@option`, but
    # sig translation is unsupported.
    when :hash, :list then ['Hash']
    when :var_ref then handle_var_ref(node)
    # A top-level constant reference, such as ::Klass
    # It contains a child node of type :const
    when :top_const_ref then convert(node.children.first)
    else
      log.warn("Unsupported sig #{node.type} node #{node.source}")
      [node.source]
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(String) }
  private_class_method def self.build_generic_type(node)
    children = node.children
    return node.source if children.empty? || node.type != :aref

    collection_type = children.first.source
    member_type = children.last.children.map { |child| build_generic_type(child) }.join(', ')

    "#{collection_type}[#{member_type}]"
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_aref(node)
    children = node.children
    # https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Parametrized_Types
    case children.first.source
    when 'T::Array', 'T::Enumerable', 'T::Range', 'T::Set'
      collection_type = children.first.source.split('::').last
      member_type = convert(children.last.children.first).join(', ')
      ["#{collection_type}<#{member_type}>"]
    when 'T::Hash'
      kv = children.last.children
      key_type = convert(kv.first).join(', ')
      value_type = convert(kv.last).join(', ')
      ["Hash{#{key_type} => #{value_type}}"]
    else
      log.info("Unsupported sig aref node #{node.source}")
      [build_generic_type(node)]
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_arg_paren(node)
    convert(node.children.first.children.first)
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_array(node)
    # https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Order-Dependent_Lists
    member_types = node.children.first.children.map { |n| convert(n) }.join(', ')
    ["Array(#{member_types})"]
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_const(node)
    source = node.source
    case source
    # YARD convention for booleans
    when 'T::Boolean' then ['Boolean']
    else [source]
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_call(node)
    children = node.children
    if children[0].source == 'T'
      t_method = IS_LEGACY_RUBY_VERSION ? children[1].source : children[2].source
      handle_t_method(t_method, node)
    else
      [node.source]
    end
  end

  sig { params(method_name: String, node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_t_method(method_name, node)
    case method_name
    # YARD doesn't have equivalent notions, so we just use the raw source
    when 'all', 'attached_class', 'class_of', 'enum', 'noreturn', 'self_type', 'type_parameter', 'untyped'
      [node.source]
    when 'any' then node.children.last.children.first.children.map { |n| convert(n) }.flatten
    # Order matters here, putting `nil` last results in a more concise
    # return syntax in the UI (superscripted `?`)
    when 'nilable' then convert(node.children.last) + ['nil']
    else
      log.warn("Unsupported T method #{node.source}")
      [node.source]
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_var_ref(node)
    # YARD convention is use singleton objects when applicable:
    # https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Literals
    case node.source
    when 'FalseClass' then ['false']
    when 'NilClass' then ['nil']
    when 'TrueClass' then ['true']
    else [node.source]
    end
  end
end
