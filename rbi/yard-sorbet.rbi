# typed: strong
module YARDSorbet
  VERSION = '0.7.0'

  module Directives
    extend T::Sig

    sig { params(docstring: T.nilable(String)).returns([YARD::Docstring, T::Array[String]]) }
    def self.extract_directives(docstring); end

    sig { params(docstring: String, directives: T::Array[String]).void }
    def self.add_directives(docstring, directives); end
  end

  module NodeUtils
    extend T::Sig
    # Node types that can have type signatures
    SigableNode = T.type_alias { T.any(YARD::Parser::Ruby::MethodDefinitionNode, YARD::Parser::Ruby::MethodCallNode) }
    ATTRIBUTE_METHODS = T.let(%i[attr attr_accessor attr_reader attr_writer].freeze, T::Array[Symbol])
    SKIP_METHOD_CONTENTS = T.let(%i[params returns].freeze, T::Array[Symbol])

    sig { params(node: YARD::Parser::Ruby::AstNode, _blk: T.proc.params(n: YARD::Parser::Ruby::AstNode).void).void }
    def self.bfs_traverse(node, &_blk); end

    sig { params(node: YARD::Parser::Ruby::AstNode).void }
    def self.delete_node(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(SigableNode) }
    def self.get_method_node(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(YARD::Parser::Ruby::AstNode) }
    def self.sibling_node(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Boolean) }
    def self.sigable_node?(node); end

    sig { params(attr_node: YARD::Parser::Ruby::MethodCallNode).returns(T::Array[String]) }
    def self.validated_attribute_names(attr_node); end
  end

  module SigToYARD
    extend T::Sig
    REF_TYPES = T.let({
      'T::Boolean' => ['Boolean'].freeze,
      'FalseClass' => ['false'].freeze,
      'NilClass' => ['nil'].freeze,
      'TrueClass' => ['true'].freeze
    }.freeze, T::Hash[String, [String]])

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
    def self.convert(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
    def self.convert_node(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
    def self.convert_node_type(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(String) }
    def self.build_generic_type(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
    def self.convert_aref(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns([String]) }
    def self.convert_array(node); end

    sig { params(node: YARD::Parser::Ruby::MethodCallNode).returns(T::Array[String]) }
    def self.convert_call(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns([String]) }
    def self.convert_collection(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns([String]) }
    def self.convert_hash(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Array[String]) }
    def self.convert_list(node); end

    sig { params(node_source: String).returns([String]) }
    def self.convert_ref(node_source); end

    sig { params(node: YARD::Parser::Ruby::MethodCallNode).returns(T::Array[String]) }
    def self.convert_t_method(node); end

    sig { params(node: YARD::Parser::Ruby::AstNode).returns([String]) }
    def self.convert_unknown(node); end
  end

  class TStructProp < T::Struct
    prop :default, T.nilable(String), immutable: true
    prop :doc, String, immutable: true
    prop :prop_name, String, immutable: true
    prop :source, String, immutable: true
    prop :types, T::Array[String], immutable: true

  end

  module TagUtils
    extend T::Sig
    VOID_RETURN_TYPE = T.let(['void'].freeze, [String])

    sig { params(docstring: YARD::Docstring, tag_name: String, name: T.nilable(String)).returns(T.nilable(YARD::Tags::Tag)) }
    def self.find_tag(docstring, tag_name, name); end

    sig do
      params(
        docstring: YARD::Docstring,
        tag_name: String,
        types: T.nilable(T::Array[String]),
        name: T.nilable(String),
        text: String
      ).void
    end
    def self.upsert_tag(docstring, tag_name, types = nil, name = nil, text = ''); end
  end

  module Handlers
    class AbstractDSLHandler < YARD::Handlers::Ruby::Base
      extend T::Sig
      TAG_TEXT = 'Subclasses must implement the `abstract` methods below.'
      CLASS_TAG_TEXT = T.let("It cannot be directly instantiated. #{TAG_TEXT}", String)

      sig { void }
      def process; end
    end

    class EnumsHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      sig { void }
      def process; end

      sig { params(node: YARD::Parser::Ruby::AstNode).returns(T::Boolean) }
      def const_assign_node?(node); end
    end

    class IncludeHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      sig { void }
      def process; end

      sig { returns(YARD::CodeObjects::NamespaceObject) }
      def included_in; end
    end

    class MixesInClassMethodsHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      sig { params(code_obj: String).returns(T.nilable(T::Array[String])) }
      def self.mixed_in_class_methods(code_obj); end

      sig { void }
      def process; end
    end

    class SigHandler < YARD::Handlers::Ruby::Base
      extend T::Sig
      # YARD types that can have docstrings attached to them
      Documentable = T.type_alias { T.any(
          YARD::CodeObjects::MethodObject, YARD::Parser::Ruby::MethodCallNode, YARD::Parser::Ruby::MethodDefinitionNode
        ) }

      sig { void }
      def process; end

      sig { params(def_node: YARD::Parser::Ruby::MethodDefinitionNode).void }
      def process_def(def_node); end

      sig { params(attr_node: YARD::Parser::Ruby::MethodCallNode).void }
      def process_attr(attr_node); end

      sig { params(attr_node: YARD::Parser::Ruby::MethodCallNode).returns(T::Boolean) }
      def merged_into_attr?(attr_node); end

      sig { params(method_objects: T::Array[YARD::CodeObjects::MethodObject]).void }
      def document_attr_methods(method_objects); end

      sig { params(attach_to: Documentable, docstring: T.nilable(String), include_params: T::Boolean).void }
      def parse_node(attach_to, docstring, include_params: true); end

      sig { params(docstring: YARD::Docstring, include_params: T::Boolean).void }
      def parse_sig(docstring, include_params: true); end

      sig { params(node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
      def parse_params(node, docstring); end

      sig { params(node: YARD::Parser::Ruby::AstNode, docstring: YARD::Docstring).void }
      def parse_return(node, docstring); end
    end

    class StructPropHandler < YARD::Handlers::Ruby::Base
      extend T::Sig

      sig { void }
      def process; end

      sig { params(object: YARD::CodeObjects::MethodObject, prop: TStructProp).void }
      def decorate_object(object, prop); end

      sig { returns(T::Boolean) }
      def immutable?; end

      sig { params(kwd: String).returns(T.nilable(String)) }
      def kw_arg(kwd); end

      sig { params(name: String).returns(TStructProp) }
      def make_prop(name); end

      sig { returns(T::Array[T.untyped]) }
      def params; end

      sig { params(object: YARD::CodeObjects::MethodObject, name: String).void }
      def register_attrs(object, name); end

      sig { params(prop: TStructProp).void }
      def update_state(prop); end
    end

    module StructClassHandler
      extend T::Sig

      requires_ancestor { YARD::Handlers::Ruby::ClassHandler }

      sig { void }
      def process; end

      sig { params(props: T::Array[TStructProp], class_ns: YARD::CodeObjects::ClassObject).void }
      def process_t_struct_props(props, class_ns); end

      sig do
        params(
          object: YARD::CodeObjects::MethodObject,
          props: T::Array[TStructProp],
          docstring: YARD::Docstring,
          directives: T::Array[String]
        ).void
      end
      def decorate_t_struct_init(object, props, docstring, directives); end

      sig { params(props: T::Array[TStructProp]).returns(T::Array[[String, T.nilable(String)]]) }
      def to_object_parameters(props); end
    end
  end
end
