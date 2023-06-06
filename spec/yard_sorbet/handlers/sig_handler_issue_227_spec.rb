# typed: strict
# frozen_string_literal: true

RSpec.describe YARDSorbet::Handlers::SigHandler do
  before do
    YARD::Registry.clear
    path = File.join(File.expand_path('../../data', __dir__), 'sig_handler_issue_227.txt')
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'Reproducing the issues' do
    it 'includes docstring from original attr_accessor' do
      expect(YARD::Registry.at('SomeThing#rate').tag(:return).types).to eq(%w[Float nil])
    end
  end
end
