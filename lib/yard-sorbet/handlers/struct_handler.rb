# typed: strict
# frozen_string_literal: true

# Handles all `const`/`prop` calls, creating accessor methods, and compiles them for later usage at the class level
# in creating a constructor
class YARDSorbet::Handlers::StructHandler < YARD::Handlers::Ruby::Base
  extend T::Sig

  handles method_call(:const), method_call(:prop)
  namespace_only

  sig { void }
  def process
    # Store the property for use in the constructor definition
    name = statement.parameters[0].jump(
      :ident, # handles most "normal" identifiers
      :kw,    # handles prop names using reserved words like `end` or `def`
      :const  # handles capitalized prop names like Foo
    ).source

    doc = statement.docstring.to_s
    source = statement.source
    types = YARDSorbet::SigToYARD.convert(statement.parameters[1])
    default_node = statement.traverse { |n| break n if n.source == 'default:' && n.type == :label }
    default = default_node.parent[1].source if default_node

    extra_state.prop_docs ||= Hash.new { |h, k| h[k] = [] }
    extra_state.prop_docs[namespace] << YARDSorbet::TStructProp.new(
      default: default,
      doc: doc,
      prop_name: name,
      source: source,
      types: types
    )

    # Create the virtual method in our current scope
    namespace.attributes[scope][name] ||= SymbolHash[read: nil, write: nil]

    object = MethodObject.new(namespace, name, scope)
    object.source = source

    # TODO: this should use `+` to delimit the attribute name when markdown is disabled
    reader_docstring = doc.empty? ? "Returns the value of attribute `#{name}`." : doc
    docstring = YARD::DocstringParser.new.parse(reader_docstring).to_docstring
    docstring.add_tag(YARD::Tags::Tag.new(:return, '', types))
    object.docstring = docstring.to_raw

    # Register the object explicitly as an attribute.
    # While `const` attributes are immutable, `prop` attributes may be reassigned.
    if statement.method_name.source == 'prop'
      namespace.attributes[scope][name][:write] = object
    end
    namespace.attributes[scope][name][:read] = object
  end
end

# Class-level handler that folds all `const` and `prop` declarations into the constructor documentation
# this needs to be injected as a module otherwise the default Class handler will overwrite documentation
#
# @note this module is included in `YARD::Handlers::Ruby::ClassHandler`
module YARDSorbet::Handlers::StructClassHandler
  extend T::Sig

  sig { void }
  def process
    super

    return if extra_state.prop_docs.nil?

    # lookup the full YARD path for the current class
    class_ns = YARD::CodeObjects::ClassObject.new(namespace, statement[0].source.gsub(/\s/, ''))
    props = extra_state.prop_docs[class_ns]

    return if props.empty?

    # Create a virtual `initialize` method with all the `prop`/`const` arguments
    # having the name :initialize & the scope :instance marks this as the constructor.
    # There is a chance that there is a custom initializer, so make sure we steal the existing docstring
    # and source
    object = YARD::CodeObjects::MethodObject.new(class_ns, :initialize, :instance)

    docstring, directives = YARDSorbet::Directives.extract_directives(object.docstring || '')

    add_t_struct_constructor_tags(docstring, props, class_ns)

    # Use kwarg style arguments, with optionals being marked with a default (unless an actual default was specified)
    object.parameters = props.map { |prop| t_struct_prop_parameter(prop) }

    # The "source" of our constructor is compromised with the props/consts
    object.source ||= props.map(&:source).join("\n")
    object.explicit ||= false # not strictly necessary

    register(object)

    object.docstring = docstring.to_raw

    YARDSorbet::Directives.add_directives(object.docstring, directives)
  end

  sig { params(prop: YARDSorbet::TStructProp).returns([String, T.nilable(String)]) }
  private def t_struct_prop_parameter(prop)
    default = prop.default || (prop.types.include?('nil') ? 'nil' : nil)
    ["#{prop.prop_name}:", default]
  end

  # Annotate the parameters of the constructor with the prop docs
  sig do
    params(
      docstring: YARD::Docstring,
      props: T::Array[YARDSorbet::TStructProp],
      class_ns: YARD::CodeObjects::ClassObject
    ).void
  end
  private def add_t_struct_constructor_tags(docstring, props, class_ns)
    props.each do |prop|
      docstring.add_tag(YARD::Tags::Tag.new(:param, prop.doc, prop.types, prop.prop_name))
    end

    docstring.add_tag(YARD::Tags::Tag.new(:return, '', class_ns))
  end
end

YARD::Handlers::Ruby::ClassHandler.include YARDSorbet::Handlers::StructClassHandler
