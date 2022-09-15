# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::NodeUtils do
  describe 'sigable_node?' do
    it 'returns false for non-method nodes' do
      node = YARD::Parser::Ruby::AstNode.new(:hash, [])
      expect(described_class.sigable_node?(node)).to be(false)
    end
  end
end
