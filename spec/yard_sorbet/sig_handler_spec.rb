# typed: false
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::SigHandler do
  before do
    YARD::Registry.clear
    path = File.join(
      File.expand_path('../data', __dir__),
      'sig_handler.rb'
    )
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'attaching to method' do
    it 'handles signatures without arguments' do
      node = YARD::Registry.at('Signatures#sig_void')
      expect(node.docstring).to eq('comment sig_void')
    end

    it 'handles chaining' do
      node = YARD::Registry.at('Signatures#sig_override_void')
      expect(node.docstring).to eq('comment sig_override_void')
    end

    it 'handles arguments' do
      node = YARD::Registry.at('Signatures#sig_arguments')
      expect(node.docstring).to eq('comment sig_arguments')
    end

    it 'handles multiline arguments' do
      node = YARD::Registry.at('Signatures#sig_multiline_arguments')
      expect(node.docstring).to eq('comment sig_multiline_arguments')
    end

    it 'handles multiline comments' do
      node = YARD::Registry.at('Signatures#sig_multiline_comments')
      expect(node.docstring).to eq("comment sig_multiline_comments\ncomment sig_multiline_comments")
    end

    it 'handles class methods' do
      node = YARD::Registry.at('Signatures.sig_class_method')
      expect(node.docstring).to eq('comment sig_class_method')
    end

    it 'handles subclasses' do
      node = YARD::Registry.at('Subclass#method')
      expect(node.docstring).to eq('with subclass')
    end

    it 'handles classes executing code' do
      node = YARD::Registry.at('ClassWithCode#foo')
      expect(node.docstring).to eq('foo')
    end

    it 'handles nested classes' do
      node = YARD::Registry.at('Outer#outer')
      expect(node.docstring).to eq('outer method')

      node = YARD::Registry.at('Outer#outer2')
      expect(node.docstring).to eq('outer method 2')

      node = YARD::Registry.at('Outer::Inner#inner')
      expect(node.docstring).to eq('inner method')
    end

    it 'handles modules' do
      node = YARD::Registry.at('MyModule.foo')
      expect(node.docstring).to eq('module function')

      node = YARD::Registry.at('MyModule#bar')
      expect(node.docstring).to eq('module instance method')
    end

    it 'handles singleton class syntax' do
      node = YARD::Registry.at('Signatures.reopening')
      expect(node.docstring).to eq('comment reopening')
    end
  end

  describe 'sig parsing' do
    it 'parses return types' do
      node = YARD::Registry.at('SigReturn#one')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'merges tags' do
      node = YARD::Registry.at('SigReturn#two')
      expect(node.tag(:return).types).to eq(['Integer'])
      expect(node.tag(:deprecated).text).to eq('do not use')
    end

    it 'overrides explicit tag' do
      node = YARD::Registry.at('SigReturn#three')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'merges comment' do
      node = YARD::Registry.at('SigReturn#four')
      expect(node.tag(:return).types).to eq(['Integer'])
      expect(node.tag(:return).text).to eq('the number four')
    end

    it 'with params' do
      node = YARD::Registry.at('SigReturn#plus_one')
      expect(node.tag(:return).types).to eq(['Float'])
    end

    it 'with T syntax' do
      node = YARD::Registry.at('SigReturn#plus')
      expect(node.tag(:return).types).to eq(%w[Numeric String])
    end

    it 'with void sig' do
      node = YARD::Registry.at('SigReturn#void_method')
      expect(node.tag(:return).types).to eq(['void'])
    end

    it 'with trailing comment on attr declaration' do
      node = YARD::Registry.at('SigReturn#attr_contains_comment')
      expect(node.tag(:return).types).to eq(['String'])
      expect(node.docstring).to eq('attr has trailing comment')
    end

    it 'with trailing comment on the method definition line' do
      node = YARD::Registry.at('SigReturn#method_definition_contains_comment')
      expect(node.tag(:return).types).to eq(['void'])
      expect(node.docstring).to eq('method definition contains comment')
    end

    it 'with trailing comment on the class method definition line' do
      node = YARD::Registry.at('SigReturn.class_method_definition_contains_comment')
      expect(node.tag(:return).types).to eq(['void'])
      expect(node.docstring).to eq('class method definition contains comment')
    end

    it 'with abstract sig' do
      node = YARD::Registry.at('SigAbstract#one')
      expect(node.tag(:abstract).text).to eq('')
    end

    it 'merges abstract tag' do
      node = YARD::Registry.at('SigAbstract#two')
      expect(node.tag(:abstract).text).to eq('subclass must implement')
    end

    it 'with returns' do
      node = YARD::Registry.at('SigAbstract#with_return')
      expect(node.tag(:abstract).text).to eq('')
      expect(node.tag(:return).types).to eq(['Boolean'])
    end

    it 'with void' do
      node = YARD::Registry.at('SigAbstract#with_void')
      expect(node.tag(:abstract).text).to eq('')
      expect(node.tag(:return).types).to eq(['void'])
    end

    it 'params' do
      node = YARD::Registry.at('SigParams#foo')
      bar_tag = node.tags.find { |t| t.name == 'bar' }
      expect(bar_tag.text).to eq('the thing')
      expect(bar_tag.types).to eq(%w[String Symbol])
      baz_tag = node.tags.find { |t| t.name == 'baz' }
      expect(baz_tag.text).to eq('the other thing')
      expect(baz_tag.types).to eq(%w[String nil])
    end

    it 'block param' do
      node = YARD::Registry.at('SigParams#blk_method')
      blk_tag = node.tags.find { |t| t.name == 'blk' }
      expect(blk_tag.types).to eq(
        ['T.proc.params(arg0: String).returns(T::Array[Hash])']
      )
      expect(node.tag(:return).types).to eq(['nil'])
    end

    it 'block param with newlines' do
      node = YARD::Registry.at('SigParams#impl_blk_method')
      blk_tag = node.tags.find { |t| t.name == 'block' }
      expect(blk_tag.types).to eq(
        ['T.proc.params( model: EmailConversation, mutator: T.untyped, ).void']
      )
      expect(node.tag(:return).types).to eq(['void'])
    end

    it 'T::Array' do
      node = YARD::Registry.at('CollectionSigs#collection')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(['Array<String>'])
    end

    it 'nested T::Array' do
      node = YARD::Registry.at('CollectionSigs#nested_collection')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(['Array<Array<String>>'])
    end

    it 'mixed T::Array' do
      node = YARD::Registry.at('CollectionSigs#mixed_collection')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(['Array<String, Symbol>'])
    end

    it 'T::Hash' do
      node = YARD::Registry.at('CollectionSigs#hash_method')
      expect(node.tag(:return).types).to eq(['Hash{String => Symbol}'])
    end

    it 'custom collection' do
      node = YARD::Registry.at('CollectionSigs#custom_collection')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(['Custom[String]'])
    end

    it 'nested custom collection' do
      node = YARD::Registry.at('CollectionSigs#nested_custom_collection')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(
        ['Array<Custom1[Custom2[String, Integer, T::Boolean], T.any(Custom3[String], Custom4[Integer])]>']
      )
    end

    it 'custom collection with inner nodes' do
      node = YARD::Registry.at('CollectionSigs#custom_collection_with_inner_nodes')
      param_tag = node.tags.find { |t| t.name == 'arr' }
      expect(param_tag.types).to eq(['Custom[T.all(T.any(Foo, Bar), T::Array[String], T::Hash[Integer, Symbol])]'])
    end

    it 'fixed Array' do
      node = YARD::Registry.at('CollectionSigs#fixed_array')
      expect(node.tag(:return).types).to eq(['Array(String, Integer)'])
    end

    it 'fixed Hash' do
      node = YARD::Registry.at('CollectionSigs#fixed_hash')
      expect(node.tag(:return).types).to eq(['Hash'])
      expect(node.visibility).to eq(:protected)
    end

    it 'fixed param Hash' do
      node = YARD::Registry.at('CollectionSigs#fixed_param_hash')
      param_tag = node.tags.find { |t| t.name == 'tos_acceptance' }
      expect(param_tag.types).to eq(%w[Hash nil])
    end

    it 'arg_paren' do
      node = YARD::Registry.at('VariousTypedSigs#arg_paren')
      expect(node.tag(:return).types).to eq(['String'])
    end

    it 'array' do
      node = YARD::Registry.at('VariousTypedSigs#array')
      expect(node.tag(:return).types).to eq(['Array(String)'])
    end

    it 'call_T_all' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_all')
      expect(node.tag(:return).types).to eq(['T.all(Foo, Bar)'])
    end

    it 'call_T_attached_class' do
      node = YARD::Registry.at('VariousTypedSigs.call_T_attached_class')
      expect(node.tag(:return).types).to eq(['T.attached_class'])
    end

    it 'call_T_class_of' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_class_of')
      expect(node.tag(:return).types).to eq(['T.class_of(String)'])
    end

    it 'call_T_enum' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_enum')
      expect(node.tag(:return).types).to eq(['T.enum'])
    end

    it 'call_T_noreturn' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_noreturn')
      expect(node.tag(:return).types).to eq(['T.noreturn'])
    end

    it 'call_T_self_type' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_self_type')
      expect(node.tag(:return).types).to eq(['T.self_type'])
    end

    it 'call_T_type_parameter' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_type_parameter')
      expect(node.tag(:return).types).to eq(['T.type_parameter'])
    end

    it 'call_T_untyped' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_untyped')
      expect(node.tag(:return).types).to eq(['T.untyped'])
    end

    it 'call_T_any' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_any')
      expect(node.tag(:return).types).to eq(%w[Integer String])
    end

    it 'call_T_nilable' do
      node = YARD::Registry.at('VariousTypedSigs#call_T_nilable')
      expect(node.tag(:return).types).to eq(%w[String nil])
    end

    it 'const_path_ref' do
      node = YARD::Registry.at('VariousTypedSigs#const_path_ref')
      expect(node.tag(:return).types).to eq(['Foo::Bar'])
    end

    it 'hash' do
      node = YARD::Registry.at('VariousTypedSigs#hash')
      expect(node.tag(:return).types).to eq(['Hash'])
    end

    it 'var_ref_false_class' do
      node = YARD::Registry.at('VariousTypedSigs#var_ref_false_class')
      expect(node.tag(:return).types).to eq(['false'])
    end

    it 'var_ref_nil_class' do
      node = YARD::Registry.at('VariousTypedSigs#var_ref_nil_class')
      expect(node.tag(:return).types).to eq(['nil'])
    end

    it 'var_ref_true_class' do
      node = YARD::Registry.at('VariousTypedSigs#var_ref_true_class')
      expect(node.tag(:return).types).to eq(['true'])
    end

    it 'var_ref' do
      node = YARD::Registry.at('VariousTypedSigs#var_ref')
      expect(node.tag(:return).types).to eq(['Foo'])
    end

    it 'top_const_ref' do
      node = YARD::Registry.at('VariousTypedSigs#top_const_ref')
      expect(node.tag(:return).types).to eq(['Foo'])
    end

    it 'handles inline visibility modifiers' do
      node = YARD::Registry.at('SigInlineVisibility#boolean_method?')
      return_tags = node.tags.select { |tag| tag.tag_name == 'return' }
      expect(return_tags.size).to eq(1)
      expect(return_tags.first.types).to eq(['Boolean'])
    end
  end

  describe 'attributes' do
    it 'handles attr_accessor getter' do
      node = YARD::Registry.at('AttrSigs#my_accessor')
      expect(node.tag(:return).types).to eq(['String'])
    end

    it 'handles attr_accessor setter' do
      node = YARD::Registry.at('AttrSigs#my_accessor=')
      expect(node.tag(:return).types).to eq(['String'])
    end

    it 'handles attr_reader' do
      node = YARD::Registry.at('AttrSigs#my_reader')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'handles attr_writer' do
      node = YARD::Registry.at('AttrSigs#my_writer=')
      expect(node.tag(:return).types).to eq(%w[Symbol nil])
    end
  end
end
