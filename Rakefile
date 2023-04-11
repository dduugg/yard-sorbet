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
namespace :typecheck do |typecheck_namespace|
  desc 'Typecheck Gemfile'
  task :gemfile do
    sh 'bundle exec srb typecheck Gemfile sorbet/rbi/contexts/gemfile.rbi'
  end

  desc 'Typecheck Rakefile'
  task :rakefile do
    sh 'bundle exec srb typecheck Rakefile sorbet/rbi/contexts/rakefile.rbi'
  end

  desc 'Typecheck spec/ files'
  task :spec do
    sh 'bundle exec srb typecheck spec/ sorbet/rbi/contexts/spec.rbi'
  end

  desc 'Typecheck library files'
  task :lib do
    sh 'bundle exec srb typecheck . bin/console yard-sorbet.gemspec'
  end

  desc 'Run all typecheck tasks'
  task :all do
    typecheck_namespace.tasks.each { Rake::Task[_1].invoke }
  end
end

task default: %i[typecheck:all rubocop spec]
