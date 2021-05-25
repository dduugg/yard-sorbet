# typed: false
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::Handlers::EnumsHandler do
  path = File.join(
    File.expand_path('../../data', __dir__),
    'enums_handler.rb'
  )

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'T::Enum subclass' do
    it('registers constants') do
      node = YARD::Registry.at('Suit')
      expect(node.constants.size).to eq(4) # rubocop:disable Sorbet/ConstantsFromStrings
    end

    describe 'enums' do
      it('attaches tags') do
        node = YARD::Registry.at('Suit::Spades')
        expect(node.tags.size).to eq(1)
        expect(node.tags.first.tag_name).to eq('see')
      end

      it('attaches docstrings') do
        node = YARD::Registry.at('Suit::Hearts')
        expect(node.docstring).to eq('The hearts suit')
      end

      it('includes serialized value') do
        node = YARD::Registry.at('Suit::Clubs')
        expect(node.value).to eq("new('Clubs')")
      end
    end
  end
end
