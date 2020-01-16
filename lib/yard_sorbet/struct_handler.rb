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

    extra_state.prop_docs ||= []
    extra_state.prop_docs << {
      doc: doc,
      prop_name: name,
      types: types,
      namespace: namespace,
      source: source
    }

    # Create the virtual method in our current scope
    namespace.attributes[scope][name] ||= SymbolHash[read: nil, write: nil]

    object = MethodObject.new(namespace, name, scope)
    object.source = source

    register(object)

    reader_docstring = doc.empty? ? "Returns the value of attribute +#{name}+." : doc
    docstring = YARD::DocstringParser.new.parse(reader_docstring).to_docstring
    docstring.add_tag(YARD::Tags::Tag.new(:return, doc, types))
    object.docstring = docstring.to_raw

    # Register the object explicitly as an attribute
    namespace.attributes[scope][name][:read] = object
  end
end

# Class-level handler that folds all `const` declarations into the constructor documentation
module YARDSorbet::StructClassHandler
  def process
    ret = super

    return ret if extra_state.prop_docs.nil? || extra_state.prop_docs.empty?

    # Create a virtual `initialize` method with all the `prop`/`const` arguments
    # having the name :initialize & the scope :instance marks this as the constructor
    object = YARD::CodeObjects::MethodObject.new(extra_state.prop_docs.first[:namespace], :initialize, :instance)

    # Copy the class doc into the virtual constructor doc
    parser = YARD::DocstringParser.new.parse(statement.docstring)
    # Directives are already parsed at this point, and there doesn't
    # seem to be an API to tweeze them from one node to another without
    # managing YARD internal state. Instead, we just extract them from
    # the raw text and re-attach them.
    directives = parser.raw_text&.split("\n")&.select do |line|
      line.start_with?('@!')
    end || []
    docstring = parser.to_docstring
    statement.docstring = nil

    # Annotate the parameters of the constructor with the prop docs
    extra_state.prop_docs.each do |prop|
      docstring.add_tag(YARD::Tags::Tag.new(:param, prop[:doc], prop[:types], prop[:prop_name]))
    end

    docstring.add_tag(YARD::Tags::Tag.new(:return, '', extra_state.prop_docs.first[:namespace]))

    # Use kwarg style arguments, with optionals being marked with a default
    object.parameters = extra_state.prop_docs.map do |prop|
      ["#{prop[:prop_name]}:", prop[:types].include?('nil') ? 'nil' : nil]
    end

    # The "source" of our constructor is compromised with the props/consts
    object.source = extra_state.prop_docs.map { |p| p[:source] }.join("\n")
    object.explicit = false # not strictly necessary

    register(object)

    directives.each do |directive|
      docstring.concat("\n#{directive}")
    end

    object.docstring = docstring.to_raw
    extra_state.prop_docs = []

    ret
  end
end

YARD::Handlers::Ruby::ClassHandler.include YARDSorbet::StructClassHandler
