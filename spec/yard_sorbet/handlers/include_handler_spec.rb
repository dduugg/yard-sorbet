# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::IncludeHandler do
  mixes_in_path = File.join(File.expand_path('../../data', __dir__), 'mixes_in_class_methods_handler.txt')
  include_path = File.join(File.expand_path('../../data', __dir__), 'include_handler.txt')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(mixes_in_path)
    YARD::Parser::SourceParser.parse(include_path)
  end

  describe 'including a module with `mixes_in_class_methods`' do
    it 'adds the class method namespace to `class_mixins`' do
      node = YARD::Registry.at('A')
      expect(node.class_mixins.map(&:to_s)).to include('M::ClassMethods')
    end

    it 'attches class method namespace to explicit receiver' do
      node = YARD::Registry.at('Receiver')
      expect(node.class_mixins.map(&:to_s)).to include('M::ClassMethods')
    end

    it 'resolves full class method namespace' do
      node = YARD::Registry.at('OuterModule::InnerClass')
      expect(node.class_mixins.map(&:to_s)).to(
        include('OuterModule::InnerModule::ClassMethodsA', 'OuterModule::InnerModule::ClassMethodsB')
      )
    end

    it 'handles multiple parameters to include' do
      node = YARD::Registry.at('C')
      expect(node.class_mixins.map(&:to_s)).to include('M::ClassMethods')
    end

    it 'includes class methods from another file' do
      node = YARD::Registry.at('C2')
      expect(node.class_mixins.map(&:to_s)).to include('M::ClassMethods')
    end
  end
end
