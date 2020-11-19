# typed: strong
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :lint do
  sh 'rubocop'
end

task :typecheck do
  sh 'srb tc --ignore=vendor/'
end

task default: %i[lint spec typecheck]
