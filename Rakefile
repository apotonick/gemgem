# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Gemgem::Application.load_tasks

namespace :test do
  desc "Test lib source"
  Rake::TestTask.new(:lib) do |t|
    t.libs << "test"
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
end

lib_task = Rake::Task["test:lib"]
test_task = Rake::Task[:test]
test_task.enhance { lib_task.invoke }