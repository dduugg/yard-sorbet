# typed: strict
# frozen_string_literal: true

require 'bundler/audit/task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

Bundler::Audit::Task.new
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new

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
namespace :typecheck do |typecheck_namespace|
  desc 'Typecheck Gemfile'
  task :gemfile do
    sh 'bundle exec srb typecheck Gemfile rbi/gemfile.rbi'
  end

  desc 'Typecheck Rakefile'
  task :rakefile do
    sh 'bundle exec srb typecheck Rakefile rbi/rakefile.rbi'
  end

  desc 'Typecheck spec/ files'
  task :spec do
    sh 'bundle exec srb typecheck spec/ rbi/spec.rbi'
  end

  desc 'Typecheck library files'
  task :lib do
    sh 'bundle exec srb typecheck'
  end

  desc 'Run all typecheck tasks'
  task :all do
    typecheck_namespace.tasks.each do |typecheck_task|
      Rake::Task[typecheck_task].invoke
    end
  end
end

task default: %i[typecheck:all rubocop spec]

desc 'Tasks to run in CI'
task ci: %i[bundle:audit default]
