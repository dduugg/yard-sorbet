# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::AbstractDSLHandler do
  path = File.join(File.expand_path('../../data', __dir__), 'abstract_dsl_handler.txt')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'interfaces' do
    it 'have @abstract tags' do
      expect(YARD::Registry.at('MyInterface').has_tag?(:abstract)).to be(true)
    end

    it 'have abstract tag text string' do
      node = YARD::Registry.at('MyInterface')
      expect(node.tags.first.text).to eq(YARDSorbet::Handlers::AbstractDSLHandler::TAG_TEXT)
    end
  end

  describe 'abstract classes' do
    it 'keep existing docstring' do
      expect(YARD::Registry.at('MyAbstractClass').docstring).to eq('An abstract class')
    end

    it 'keep existing tags' do
      expect(YARD::Registry.at('MyAbstractClass').tag(:note).text).to eq('this class is abstract')
    end

    it 'have abstract tags' do
      expect(YARD::Registry.at('MyAbstractClass').has_tag?(:abstract)).to be(true)
    end

    it 'have abstract tag text string' do
      node = YARD::Registry.at('MyAbstractClass')
      expect(node.tag(:abstract).text).to eq(YARDSorbet::Handlers::AbstractDSLHandler::CLASS_TAG_TEXT)
    end
  end

  describe 'When existing abstract tag exists' do
    it 'does not create a redundant tag' do
      expect(YARD::Registry.at('MyTaggedAbstractModule').tags(:abstract).size).to be(1)
    end

    it 'preserves tag text' do
      node = YARD::Registry.at('MyTaggedAbstractModule')
      expect(node.tag(:abstract).text).to eq('Existing abstract tag')
    end
  end
end
