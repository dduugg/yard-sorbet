# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::EnumsHandler do
  path = File.join(File.expand_path('../../data', __dir__), 'enums_handler.txt')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'T::Enum subclass' do
    it 'registers constants' do
      node = YARD::Registry.at('Suit')
      expect(node.constants.size).to eq(4) # rubocop:disable Sorbet/ConstantsFromStrings
    end

    describe 'enums' do
      it 'keep existing tag count' do
        expect(YARD::Registry.at('Suit::Spades').tags.size).to be(1)
      end

      it 'attach existing tags' do
        node = YARD::Registry.at('Suit::Spades')
        expect(node.tag(:see).name).to eq('https://en.wikipedia.org/wiki/Spades_(suit)')
      end

      it 'attach docstrings' do
        node = YARD::Registry.at('Suit::Hearts')
        expect(node.docstring).to eq('The hearts suit')
      end

      it 'include serialized values' do
        node = YARD::Registry.at('Suit::Clubs')
        expect(node.value).to eq("new('Clubs')")
      end
    end
  end
end
