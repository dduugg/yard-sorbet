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

    extra_state.prop_docs ||= Hash.new { |h, k| h[k] = [] }
    extra_state.prop_docs[namespace] << {
      doc: doc,
      prop_name: name,
      types: types,
      source: source
    }

    # Create the virtual method in our current scope
    namespace.attributes[scope][name] ||= SymbolHash[read: nil, write: nil]

    object = MethodObject.new(namespace, name, scope)
    object.source = source

    register(object)

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

    return ret if extra_state.prop_docs.nil?

    # lookup the full YARD path for the current class
    class_ns = YARD::CodeObjects::ClassObject.new(namespace, statement[0].source.gsub(/\s/, ''))
    return ret if extra_state.prop_docs[class_ns].empty?

    props = extra_state.prop_docs[class_ns]

    # Create a virtual `initialize` method with all the `prop`/`const` arguments
    # having the name :initialize & the scope :instance marks this as the constructor
    object = YARD::CodeObjects::MethodObject.new(class_ns, :initialize, :instance)

    docstring = YARD::DocstringParser.new.parse('').to_docstring

    # Annotate the parameters of the constructor with the prop docs
    props.each do |prop|
      docstring.add_tag(YARD::Tags::Tag.new(:param, prop[:doc], prop[:types], prop[:prop_name]))
    end

    docstring.add_tag(YARD::Tags::Tag.new(:return, '', class_ns))

    # Use kwarg style arguments, with optionals being marked with a default
    object.parameters = props.map do |prop|
      ["#{prop[:prop_name]}:", prop[:types].include?('nil') ? 'nil' : nil]
    end

    # The "source" of our constructor is compromised with the props/consts
    object.source = props.map { |p| p[:source] }.join("\n")
    object.explicit = false # not strictly necessary

    register(object)

    object.docstring = docstring.to_raw

    ret
  end
end

YARD::Handlers::Ruby::ClassHandler.include YARDSorbet::StructClassHandler
