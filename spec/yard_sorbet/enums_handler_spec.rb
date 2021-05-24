# typed: false
# frozen_string_literal: true

require 'yard'

RSpec.describe YARDSorbet::EnumsHandler do
  path = File.join(
    File.expand_path('../data', __dir__),
    'enums_handler.rb'
  )

  before do
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(path)
  end

  describe 'enums' do
  end
end
