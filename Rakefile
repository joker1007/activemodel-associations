require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :spec do
  %w(activerecord-41 activerecord-412 activerecord-42 activerecord-50 activerecord-master).each do |gemfile|
    desc "Run Tests by #{gemfile}.gemfile"
    task gemfile do
      Bundler.with_clean_env do
        sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle install --path .bundle"
        sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake -t spec"
      end
    end
  end

  desc "Run All Tests"
  task :all do
    %w(activerecord-41 activerecord-412 activerecord-42 activerecord-50 activerecord-master).each do |gemfile|
      Rake::Task["spec:#{gemfile}"].invoke
    end
  end
end
