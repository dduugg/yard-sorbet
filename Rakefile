# typed: strong
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop)

desc 'Typecheck files with Sorbet'
task :typecheck do
  sh 'srb tc'
end

task default: %i[rubocop spec typecheck]
