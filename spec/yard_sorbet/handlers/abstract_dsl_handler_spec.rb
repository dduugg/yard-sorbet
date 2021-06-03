# typed: strict
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::Handlers::AbstractDSLHandler do
  path = File.join(
    File.expand_path('../../data', __dir__),
    'abstract_dsl_handler.rb'
  )

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'modules with abstract!/interface! declarations' do
    it('apply @abstract tags') do
      node = YARD::Registry.at('MyInterface')
      expect(node.tags.size).to eq(1)
      expect(node.has_tag?(:abstract)).to be(true)
      expect(node.tags.first.text).to eq(YARDSorbet::Handlers::AbstractDSLHandler::TAG_TEXT)
    end

    it('apply class text to abstract classes') do
      node = YARD::Registry.at('MyAbstractClass')
      expect(node.docstring).to eq('An abstract class')
      expect(node.tags.size).to eq(2)
      expect(node.has_tag?(:abstract)).to be(true)
      abstract_tag = node.tags.find { |tag| tag.tag_name == 'abstract' }
      expect(abstract_tag.text).to eq(YARDSorbet::Handlers::AbstractDSLHandler::CLASS_TAG_TEXT)
    end

    it('keep existing @abstract tags') do
      node = YARD::Registry.at('MyTaggedAbstractModule')
      expect(node.has_tag?(:abstract)).to be(true)
      abstract_tag = node.tags.find { |tag| tag.tag_name == 'abstract' }
      expect(abstract_tag.text).to eq('Existing abstract tag')
    end
  end
end
