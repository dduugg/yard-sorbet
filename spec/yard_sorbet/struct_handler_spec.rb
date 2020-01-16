# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::StructHandler do
  before do
    YARD::Registry.clear
    path = File.join(
      File.expand_path('../data', __dir__),
      'struct_handler.rb.txt'
    )
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'constructor' do
    it 'has the appropriate parameters' do
      node = YARD::Registry.at('PersonStruct#initialize')
      expect(node.parameters).to eq([['name:', nil], ['age:', nil], ['optional:', 'nil'], ['mystery:', nil]])
    end
  end

  describe 'attributes' do
    it 'creates accessor method docs' do
      node = YARD::Registry.at('PersonStruct#optional')
      expect(node.tag(:return).types).to eq(%w[String nil])
    end

    it 'attaches the docstring to the accessor' do
      node = YARD::Registry.at('PersonStruct#age')
      expect(node.docstring).to eq('An age')
    end

    it 'creates a docstring if it does not exist' do
      node = YARD::Registry.at('PersonStruct#mystery')
      expect(node.docstring).to eq('Returns the value of attribute +mystery+.')
    end
  end
end
