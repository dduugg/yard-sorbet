# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::SigHandler do
  # The :all (and corresponding rubocop disable) isn't strictly necessary, but it speeds up tests considerably
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    YARD::Registry.clear
    path = File.join(File.expand_path('../../data', __dir__), 'sig_handler.txt')
    YARD::Parser::SourceParser.parse(path)
    rbi_path = File.join(File.expand_path('../../data', __dir__), 'sig_handler.rbi.txt')
    YARD::Parser::SourceParser.parse(rbi_path)
  end

  describe 'Merging an RBI file' do
    it 'includes docstring from original attr_accessor' do
      expect(YARD::Registry.at('Merge::A#a_foo').docstring).to eq('annotated attr_accessor')
    end

    it 'merges attr_accessor sig' do
      expect(YARD::Registry.at('Merge::A#a_foo').tag(:return).types).to eq(['Numeric'])
    end

    it 'includes docstring from original attr_reader' do
      expect(YARD::Registry.at('Merge::A#a_bar').docstring).to eq('Returns the value of attribute a_bar.')
    end

    it 'merges attr_reader sig' do
      expect(YARD::Registry.at('Merge::A#a_bar').tag(:return).types).to eq(%w[String nil])
    end

    it 'includes docstring from original attr_writer' do
      expect(YARD::Registry.at('Merge::A#a_baz=').docstring).to eq('Sets the attribute a_baz')
    end

    it 'merges attr_writer sig' do
      expect(YARD::Registry.at('Merge::A#a_baz=').tag(:return).types).to eq(['Integer'])
    end

    it 'includes docstring from original instance def' do
      expect(YARD::Registry.at('Merge::A#foo').docstring).to eq('The foo instance method for A')
    end

    it 'merges instance def sig' do
      expect(YARD::Registry.at('Merge::A#foo').tag(:return).types).to eq(['String'])
    end

    it 'includes docstring from original singleton def' do
      expect(YARD::Registry.at('Merge::A.bar').docstring).to eq('The bar singleton method for A')
    end

    it 'merges singleton def sig' do
      expect(YARD::Registry.at('Merge::A.bar').tag(:return).types).to eq(['Float'])
    end

    it 'preserves the visibility of the original method' do
      expect(YARD::Registry.at('Merge::A#baz').visibility).to be(:private)
    end

    it 'merges sig return type with return tag' do
      expect(YARD::Registry.at('Merge::A#bat').tag(:return).types).to eq(['Integer'])
    end

    it 'merges return tag comment with sig return type' do
      expect(YARD::Registry.at('Merge::A#bat').tag(:return).text).to eq('the result')
    end

    it 'overwrites the prior docstring when a new docstring exists' do
      expect(YARD::Registry.at('Merge::A#xyz').docstring).to eq('new docstring')
    end
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

    it 'handles module singleton methods' do
      node = YARD::Registry.at('MyModule.foo')
      expect(node.docstring).to eq('module function')
    end

    it 'handles module instance methods' do
      node = YARD::Registry.at('MyModule#bar')
      expect(node.docstring).to eq('module instance method')
    end

    it 'handles singleton class syntax' do
      node = YARD::Registry.at('Signatures.reopening')
      expect(node.docstring).to eq('comment reopening')
    end
  end

  describe 'nested classes' do
    it 'keep docstrings for outer class methods preceding inner classe' do
      expect(YARD::Registry.at('Outer#outer').docstring).to eq('outer method')
    end

    it 'keep docstrings for inner class methods' do
      expect(YARD::Registry.at('Outer#outer2').docstring).to eq('outer method 2')
    end

    it 'keep docstrings for outer class methods following inner class' do
      expect(YARD::Registry.at('Outer::Inner#inner').docstring).to eq('inner method')
    end
  end

  describe 'sig parsing' do
    it 'parses return types' do
      node = YARD::Registry.at('SigReturn#one')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'merges docstring tags' do
      expect(YARD::Registry.at('SigReturn#two').tag(:deprecated).text).to eq('do not use')
    end

    it 'merges sig tags' do
      expect(YARD::Registry.at('SigReturn#two').tag(:return).types).to eq(['Integer'])
    end

    it 'overrides explicit tag' do
      node = YARD::Registry.at('SigReturn#three')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'merges sig return type with return tag' do
      expect(YARD::Registry.at('SigReturn#four').tag(:return).types).to eq(['Integer'])
    end

    it 'merges return tag comment with sig return type' do
      expect(YARD::Registry.at('SigReturn#four').tag(:return).text).to eq('the number four')
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

    it 'with abstract sig' do
      node = YARD::Registry.at('SigAbstract#one')
      expect(node.tag(:abstract).text).to eq('')
    end

    it 'merges abstract tag' do
      node = YARD::Registry.at('SigAbstract#two')
      expect(node.tag(:abstract).text).to eq('subclass must implement')
    end

    it 'merges abstract tag with returns type' do
      expect(YARD::Registry.at('SigAbstract#with_return').tag(:abstract).text).to eq('')
    end

    it 'merges return type with abstract tag' do
      expect(YARD::Registry.at('SigAbstract#with_return').tag(:return).types).to eq(['Boolean'])
    end

    it 'merges abstract tag with void' do
      expect(YARD::Registry.at('SigAbstract#with_void').tag(:abstract).text).to eq('')
    end

    it 'merges void return type with abstract tag' do
      expect(YARD::Registry.at('SigAbstract#with_void').tag(:return).types).to eq(['void'])
    end

    it 'parses T.any param text' do
      bar_tag = YARD::Registry.at('SigParams#foo').tags.find { _1.name == 'bar' }
      expect(bar_tag.text).to eq('the thing')
    end

    it 'parses T.any param types' do
      bar_tag = YARD::Registry.at('SigParams#foo').tags.find { _1.name == 'bar' }
      expect(bar_tag.types).to eq(%w[String Symbol])
    end

    it 'parses T.nilable param text' do
      baz_tag = YARD::Registry.at('SigParams#foo').tags.find { _1.name == 'baz' }
      expect(baz_tag.text).to eq('the other thing')
    end

    it 'parses T.nilable param type' do
      baz_tag = YARD::Registry.at('SigParams#foo').tags.find { _1.name == 'baz' }
      expect(baz_tag.types).to eq(%w[String nil])
    end

    it 'parses block param type' do
      blk_tag = YARD::Registry.at('SigParams#blk_method').tags.find { _1.name == 'blk' }
      expect(blk_tag.types).to eq(['T.proc.params(arg0: String).returns(T::Array[Hash])'])
    end

    it 'parses return type of method with block param' do
      expect(YARD::Registry.at('SigParams#blk_method').tag(:return).types).to eq(['nil'])
    end

    it 'parses type of block param with newlines' do
      blk_tag = YARD::Registry.at('SigParams#impl_blk_method').tags.find { _1.name == 'block' }
      expect(blk_tag.types).to eq(['T.proc.params( model: EmailConversation, mutator: T.untyped, ).void'])
    end

    it 'parses return type of method with block param type with newlines' do
      expect(YARD::Registry.at('SigParams#impl_blk_method').tag(:return).types).to eq(['void'])
    end

    it 'T::Array' do
      node = YARD::Registry.at('CollectionSigs#collection')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(['Array<String>'])
    end

    it 'nested T::Array' do
      node = YARD::Registry.at('CollectionSigs#nested_collection')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(['Array<Array<String>>'])
    end

    it 'mixed T::Array' do
      node = YARD::Registry.at('CollectionSigs#mixed_collection')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(['Array<String, Symbol>'])
    end

    it 'T::Hash' do
      node = YARD::Registry.at('CollectionSigs#hash_method')
      expect(node.tag(:return).types).to eq(['Hash{String => Symbol}'])
    end

    it 'custom collection' do
      node = YARD::Registry.at('CollectionSigs#custom_collection')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(['Custom[String]'])
    end

    it 'nested custom collection' do
      node = YARD::Registry.at('CollectionSigs#nested_custom_collection')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(
        ['Array<Custom1[Custom2[String, Integer, T::Boolean], T.any(Custom3[String], Custom4[Integer])]>']
      )
    end

    it 'custom collection with inner nodes' do
      node = YARD::Registry.at('CollectionSigs#custom_collection_with_inner_nodes')
      param_tag = node.tags.find { _1.name == 'arr' }
      expect(param_tag.types).to eq(['Custom[T.all(T.any(Foo, Bar), T::Array[String], T::Hash[Integer, Symbol])]'])
    end

    it 'fixed Array' do
      node = YARD::Registry.at('CollectionSigs#fixed_array')
      expect(node.tag(:return).types).to eq(['Array<(String, Integer)>'])
    end

    describe 'of fixed Hash' do
      it 'has Hash return type' do
        expect(YARD::Registry.at('CollectionSigs#fixed_hash').tag(:return).types).to eq(['Hash'])
      end

      it 'preserves visibility modifier' do
        expect(YARD::Registry.at('CollectionSigs#fixed_hash').visibility).to be(:protected)
      end
    end

    it 'fixed param Hash' do
      node = YARD::Registry.at('CollectionSigs#fixed_param_hash')
      param_tag = node.tags.find { _1.name == 'tos_acceptance' }
      expect(param_tag.types).to eq(%w[Hash nil])
    end

    it 'arg_paren' do
      node = YARD::Registry.at('VariousTypedSigs#arg_paren')
      expect(node.tag(:return).types).to eq(['String'])
    end

    it 'array' do
      node = YARD::Registry.at('VariousTypedSigs#array')
      expect(node.tag(:return).types).to eq(['Array<(String)>'])
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
      expect(node.tag(:return).types).to eq(['::Foo'])
    end

    it 'renders nested array types' do
      node = YARD::Registry.at('VariousTypedSigs#nested_array_return')
      expect(node.tag(:return).types).to eq(['Array<Array<(String, [String, nil])>>'])
    end

    it 'has single return tag when inline modifier exists' do
      node = YARD::Registry.at('SigInlineVisibility#boolean_method?')
      return_tags = node.tags.select { _1.tag_name == 'return' }
      expect(return_tags.size).to eq(1)
    end

    it 'parses return type with inline modifier' do
      node = YARD::Registry.at('SigInlineVisibility#boolean_method?')
      expect(node.tag(:return).types).to eq(['Boolean'])
    end

    it 'parses void methods with proc params' do
      expect(YARD::Registry.at('BlockDSL#initialize').tag(:return).types).to eq(['void'])
    end

    it 'handles omitting parens' do
      node = YARD::Registry.at('SigReturn#no_parens')
      expect(node.tag(:return).types).to eq(['Integer'])
    end

    it 'parses const nodes' do
      node = YARD::Registry.at('Nodes#returns_const')
      expect(node.tag(:return).types).to eq(['INT'])
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

    it 'handles parens' do
      node = YARD::Registry.at('AttrSigs#with_parens=')
      expect(node.tag(:return).types).to eq(%w[Boolean])
    end
  end

  describe 'parsing with trailing comments' do
    describe 'on attr declaration' do
      it 'preserves return type' do
        node = YARD::Registry.at('SigReturn#attr_contains_comment')
        expect(node.tag(:return).types).to eq(['String'])
      end

      it 'preserves docstring' do
        node = YARD::Registry.at('SigReturn#attr_contains_comment')
        expect(node.docstring).to eq('attr has trailing comment')
      end
    end

    describe 'on the method definition line' do
      it 'preserves return type' do
        node = YARD::Registry.at('SigReturn#method_definition_contains_comment')
        expect(node.tag(:return).types).to eq(['void'])
      end

      it 'preserves docstring' do
        node = YARD::Registry.at('SigReturn#method_definition_contains_comment')
        expect(node.docstring).to eq('method definition contains comment')
      end
    end

    describe 'with trailing comment on the class method definition line' do
      it 'preserves return type' do
        node = YARD::Registry.at('SigReturn.class_method_definition_contains_comment')
        expect(node.tag(:return).types).to eq(['void'])
      end

      it 'preserves docstring' do
        node = YARD::Registry.at('SigReturn.class_method_definition_contains_comment')
        expect(node.docstring).to eq('class method definition contains comment')
      end
    end
  end

  describe 'Unparsable sigs' do
    before do
      allow(log).to receive(:warn)
      YARD::Parser::SourceParser.parse_string(<<~RUBY)
        class Test
          CONST = :foo
          sig { returns(Integer) }
          attr_reader CONST
        end
      RUBY
    end

    it 'warn when parsing an attr* with a constant param' do
      expect(log).to have_received(:warn).with(/Undocumentable CONST/).twice
    end
  end

  describe 'sig-to-yard conversion' do
    before do
      allow(log).to receive(:error)
      YARD::Parser::SourceParser.parse_string(<<~RUBY)
        class MyClass
          sig { returns(T.nilable(T::Boolean)) }
          def my_method; end
        end
      RUBY
    end

    it 'does not error when parsing T.nilable' do
      expect(log).not_to have_received(:error)
    end
  end
end
