# typed: strict
# frozen_string_literal: true

# Handles all `const`/`prop` calls, creating accessor methods, and compiles them for later usage at the class level
# in creating a constructor
class YARDSorbet::Handlers::StructPropHandler < YARD::Handlers::Ruby::Base
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
