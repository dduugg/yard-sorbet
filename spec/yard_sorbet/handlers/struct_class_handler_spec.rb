# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::StructClassHandler do
  path = File.join(File.expand_path('../../data', __dir__), 'struct_handler.rb')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'constructor' do
    it 'has the appropriate parameters' do
      node = YARD::Registry.at('PersonStruct#initialize')
      expect(node.parameters).to eq(
        [['name:', nil], ['age:', nil], ['optional:', 'nil'], ['writable:', nil], ['mystery:', nil]]
      )
    end

    it 'uses the docstring from an explicit initializer' do
      node = YARD::Registry.at('SpecializedPersonStruct#initialize')
      expect(node.docstring).to eq('This is a special intializer')
    end

    it 'handles exceptional prop names' do
      node = YARD::Registry.at('ExceptionalPersonStruct#initialize')
      expect(node.parameters).to eq([['end:', nil], ['Foo:', nil]])
    end
  end
end
