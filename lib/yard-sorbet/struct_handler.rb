# typed: true
# frozen_string_literal: true

# Handle all `const` calls, creating accessor methods, and compiles them for later usage at the class level
# in creating a constructor
class YARDSorbet::StructHandler < YARD::Handlers::Ruby::Base
  handles method_call(:const)
  namespace_only

  def process
    # Store the property for use in the constructor definition
    name = statement.parameters[0].jump(:ident).source
    doc = statement.docstring.to_s
    source = statement.source
    types = YARDSorbet::SigToYARD.convert(statement.parameters[1])
    default_node = statement.traverse { |n| break n if n.source == 'default:' && n.type == :label }
    default = default_node.parent[1].source if default_node

    extra_state.prop_docs ||= Hash.new { |h, k| h[k] = [] }
    extra_state.prop_docs[namespace] << {
      doc: doc,
      prop_name: name,
      types: types,
      source: source,
      default: default
    }

    # Create the virtual method in our current scope
    namespace.attributes[scope][name] ||= SymbolHash[read: nil, write: nil]

    object = MethodObject.new(namespace, name, scope)
    object.source = source

    reader_docstring = doc.empty? ? "Returns the value of attribute +#{name}+." : doc
    docstring = YARD::DocstringParser.new.parse(reader_docstring).to_docstring
    docstring.add_tag(YARD::Tags::Tag.new(:return, '', types))
    object.docstring = docstring.to_raw

    # Register the object explicitly as an attribute
    namespace.attributes[scope][name][:read] = object
  end
end

# Class-level handler that folds all `const` declarations into the constructor documentation
# this needs to be injected as a module otherwise the default Class handler will overwrite documentation
module YARDSorbet::StructClassHandler
  def process
    ret = super

    return ret if T.unsafe(self).extra_state.prop_docs.nil?

    # lookup the full YARD path for the current class
    class_ns = YARD::CodeObjects::ClassObject.new(
      T.unsafe(self).namespace, T.unsafe(self).statement[0].source.gsub(/\s/, '')
    )
    props = T.unsafe(self).extra_state.prop_docs[class_ns]

    return ret if props.empty?

    # Create a virtual `initialize` method with all the `prop`/`const` arguments
    # having the name :initialize & the scope :instance marks this as the constructor.
    # There is a chance that there is a custom initializer, so make sure we steal the existing docstring
    # and source
    object = YARD::CodeObjects::MethodObject.new(class_ns, :initialize, :instance)

    docstring, directives = YARDSorbet::Directives.extract_directives(object.docstring || '')

    # Annotate the parameters of the constructor with the prop docs
    props.each do |prop|
      docstring.add_tag(YARD::Tags::Tag.new(:param, prop[:doc], prop[:types], prop[:prop_name]))
    end

    docstring.add_tag(YARD::Tags::Tag.new(:return, '', class_ns))

    # Use kwarg style arguments, with optionals being marked with a default (unless an actual default was specified)
    object.parameters = props.map do |prop|
      default = prop[:default] || (prop[:types].include?('nil') ? 'nil' : nil)
      ["#{prop[:prop_name]}:", default]
    end

    # The "source" of our constructor is compromised with the props/consts
    object.source ||= props.map { |p| p[:source] }.join("\n")
    object.explicit ||= false # not strictly necessary

    T.unsafe(self).register(object)

    object.docstring = docstring.to_raw

    YARDSorbet::Directives.add_directives(object.docstring, directives)

    ret
  end
end

YARD::Handlers::Ruby::ClassHandler.include YARDSorbet::StructClassHandler
