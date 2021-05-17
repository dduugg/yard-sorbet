# typed: false
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop)

desc 'Update sorbet rbi files'
task :rbi do
  sh 'bundle update'
  sh 'bundle clean'
  sh 'rm -r sorbet/rbi'
  sh 'bundle exec srb rbi sorbet-typed'
  sh 'bundle exec srb rbi gems'
  sh 'bundle exec srb rbi hidden-definitions'
  sh 'bundle exec srb rbi todo'
end

desc 'Typecheck files with sorbet'
task :typecheck do
  # data files for tests should individually typecheck
  Dir.glob('spec/data/*.rb') do |file|
    sh "bundle exec srb typecheck #{file}"
  end
  sh 'bundle exec srb typecheck'
end

task default: %i[rubocop spec typecheck]
