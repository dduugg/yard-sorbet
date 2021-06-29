# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::SigHandler do
  path = File.join(File.expand_path('../../data', __dir__), 'sig_handler_ignored.rb')

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'sig parsing' do
    it 'handles unsupported node types' do
      node = YARD::Registry.at('Weird#one')
      expect(node.tag(:return).type).to eq('1')
    end
  end
end
