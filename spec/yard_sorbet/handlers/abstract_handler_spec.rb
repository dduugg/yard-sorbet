# typed: false
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::Handlers::AbstractHandler do
  path = File.join(
    File.expand_path('../../data', __dir__),
    'abstract_handler.rb'
  )

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'abstract classes' do
    it('have @abstract tags') do
      node = YARD::Registry.at('MyAbstractClass')
      expect(node.tags.size).to eq(2)
      expect(node.has_tag?(:abstract)).to be(true)
    end
  end
end
