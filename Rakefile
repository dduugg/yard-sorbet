# typed: strong
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Lint files with Rubocop'
task :lint do
  sh 'rubocop'
end

desc 'Typecheck files with Sorbet'
task :typecheck do
  sh 'srb tc --ignore=vendor/'
end

task default: %i[lint spec typecheck]
