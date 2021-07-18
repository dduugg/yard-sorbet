# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::StructClassHandler do
  path = File.join(File.expand_path('../../data', __dir__), 'struct_handler.rb')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'constructor' do
    it 'has the parameter tag type' do
      node = YARD::Registry.at('PersonStruct#initialize')
      tag = YARDSorbet::TagUtils.find_tag(node.docstring, 'param', 'name')
      expect(tag&.types).to eq(['String'])
    end

    it 'has the nilable parameter tag type' do
      node = YARD::Registry.at('PersonStruct#initialize')
      tag = YARDSorbet::TagUtils.find_tag(node.docstring, 'param', 'optional')
      expect(tag&.types).to eq(%w[String nil])
    end

    it 'return tag has type annotation' do
      node = YARD::Registry.at('PersonStruct#initialize')
      expect(node.tag(:return).type).to eq('void')
    end

    it 'uses the docstring from an explicit initializer' do
      node = YARD::Registry.at('SpecializedPersonStruct#initialize')
      expect(node.docstring).to eq('This is a special intializer')
    end

    it 'handles keyword node prop names' do
      node = YARD::Registry.at('ExceptionalPersonStruct#initialize')
      tag = YARDSorbet::TagUtils.find_tag(node.docstring, 'param', 'end')
      expect(tag&.types).to eq(['String'])
    end

    it 'handles const node prop names' do
      node = YARD::Registry.at('ExceptionalPersonStruct#initialize')
      tag = YARDSorbet::TagUtils.find_tag(node.docstring, 'param', 'Foo')
      expect(tag&.types).to eq(['String'])
    end
  end
end
