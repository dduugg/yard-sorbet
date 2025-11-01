# typed: strict
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new

desc 'Typecheck files with sorbet'
task :typecheck do
  sh 'bundle exec srb typecheck'
end

desc 'Generate RBI files with tapioca'
task :rbi do
  sh 'bin/tapioca gems'
end

task default: %i[typecheck rubocop spec]
