# typed: strict
# frozen_string_literal: true

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

    process_t_struct_props(props, class_ns)
  end

  # Create a virtual `initialize` method with all the `prop`/`const` arguments
  sig { params(props: T::Array[YARDSorbet::TStructProp], class_ns: YARD::CodeObjects::ClassObject).void }
  private def process_t_struct_props(props, class_ns)
    # having the name :initialize & the scope :instance marks this as the constructor.
    object = YARD::CodeObjects::MethodObject.new(class_ns, :initialize, :instance)
    # There is a chance that there is a custom initializer, so make sure we steal the existing docstring
    # and source
    docstring, directives = YARDSorbet::Directives.extract_directives(object.docstring)
    props.each do |prop|
      docstring.add_tag(YARD::Tags::Tag.new(:param, prop.doc, prop.types, prop.prop_name))
    end
    docstring.add_tag(YARD::Tags::Tag.new(:return, '', class_ns))
    decortate_t_struct_init(object, props, docstring, directives)
    register(object)
  end

  sig do
    params(
      object: YARD::CodeObjects::MethodObject,
      props: T::Array[YARDSorbet::TStructProp],
      docstring: YARD::Docstring,
      directives: T::Array[String]
    ).void
  end
  private def decortate_t_struct_init(object, props, docstring, directives)
    # Use kwarg style arguments, with optionals being marked with a default (unless an actual default was specified)
    object.parameters = props.map do |prop|
      default = prop.default || (prop.types.include?('nil') ? 'nil' : nil)
      ["#{prop.prop_name}:", default]
    end
    # The "source" of our constructor is the field declarations
    object.source ||= props.map(&:source).join("\n")
    object.explicit ||= false # not strictly necessary
    object.docstring = docstring.to_raw
    YARDSorbet::Directives.add_directives(object.docstring, directives)
  end
end

YARD::Handlers::Ruby::ClassHandler.include YARDSorbet::Handlers::StructClassHandler
