# typed: false
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::StructHandler do
  path = File.join(
    File.expand_path('../data', __dir__),
    'struct_handler.rb.txt'
  )

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'constructor' do
    it('has the appropriate parameters') do
      node = YARD::Registry.at('PersonStruct#initialize')
      expect(node.parameters).to eq(
        [
          ['name:', nil],
          ['age:', nil],
          ['optional:', 'nil'],
          ['writable:', nil],
          ['mystery:', nil]
        ]
      )
    end

    it('uses the docstring from an explicit initializer') do
      node = YARD::Registry.at('SpecializedPersonStruct#initialize')
      expect(node.docstring).to eq('This is a special intializer')
    end
  end

  describe 'attributes' do
    it('creates accessor method docs') do
      node = YARD::Registry.at('PersonStruct#optional')
      expect(node.tag(:return).types).to eq(%w[String nil])
    end

    it('attaches the docstring to the accessor') do
      node = YARD::Registry.at('PersonStruct#age')
      expect(node.docstring).to eq('An age')
    end

    it('creates a docstring if it does not exist') do
      node = YARD::Registry.at('PersonStruct#mystery')
      expect(node.docstring).to eq('Returns the value of attribute +mystery+.')
    end

    it('handles default values appropriately') do
      node = YARD::Registry.at('DefaultPersonStruct#initialize')
      expect(node.parameters).to eq([['defaulted:', "'hello'"]])
    end

    it('marks `const` attributes read-only') do
      node = YARD::Registry.at('PersonStruct#age')
      expect(node.writer?).to eq(false)
    end

    it('does not mark `prop` attributes read-only') do
      node = YARD::Registry.at('PersonStruct#writable')
      expect(node.writer?).to eq(true)
    end

    it('does not trigger a redundant call to `register`') do
      YARD::Registry.clear
      expect_any_instance_of(described_class).not_to receive(:register) # rubocop:disable RSpec/AnyInstance
      YARD::Parser::SourceParser.parse(path)
    end
  end
end
