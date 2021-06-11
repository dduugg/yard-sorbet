# typed: strict
# frozen_string_literal: true

# Translate `sig` type syntax to `YARD` type syntax.
module YARDSorbet::SigToYARD
  extend T::Sig

  # @see https://yardoc.org/types.html
  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  def self.convert(node)
    types = convert_type(node)
    # scrub newlines, as they break the YARD parser
    types.map { |type| type.gsub(/\n\s*/, ' ') }
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.convert_type(node)
    return handle_call(node) if node.is_a? YARD::Parser::Ruby::MethodCallNode

    case node.type
    when :aref then handle_aref(node)
    when :arg_paren then handle_arg_paren(node)
    when :array then handle_array(node)
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
    when :top_const_ref then convert(node.first)
    else
      log.warn("Unsupported sig #{node.type} node #{node.source}")
      [node.source]
    end
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(String) }
  private_class_method def self.build_generic_type(node)
    return node.source if node.empty? || node.type != :aref

    collection_type = node.first.source
    member_type = node.last.children.map { |child| build_generic_type(child) }.join(', ')

    "#{collection_type}[#{member_type}]"
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_aref(node)
    # https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Parametrized_Types
    case node.first.source
    when 'T::Array', 'T::Enumerable', 'T::Range', 'T::Set'
      collection_type = node.first.source.split('::').last
      member_type = convert(node.last.first).join(', ')
      ["#{collection_type}<#{member_type}>"]
    when 'T::Hash'
      kv = node.last.children
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
    convert(node.first.first)
  end

  sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_array(node)
    # https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Order-Dependent_Lists
    member_types = node.first.children.map { |n| convert(n) }.join(', ')
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

  sig { params(node: YARD::Parser::Ruby::MethodCallNode).returns(T::Array[String]) }
  private_class_method def self.handle_call(node)
    if node.namespace.source == 'T'
      handle_t_method(node.method_name(true), node)
    else
      [node.source]
    end
  end

  sig { params(method_name: Symbol, node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
  private_class_method def self.handle_t_method(method_name, node)
    case method_name
    when :any then node.last.first.children.map { |n| convert(n) }.flatten
    # Order matters here, putting `nil` last results in a more concise
    # return syntax in the UI (superscripted `?`)
    when :nilable then convert(node.last) + ['nil']
    when :all, :attached_class, :class_of, :enum, :noreturn, :self_type, :type_parameter, :untyped
      # YARD doesn't have equivalent notions, so we just use the raw source
      [node.source]
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
