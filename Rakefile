require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubygems/package_task"
require "rdoc/task"

$: << File.join(File.dirname(__FILE__),"lib")

include Rake::DSL

gemspec = eval(File.read("fittings.gemspec"))

Gem::PackageTask.new(gemspec) {}

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end


task :default => :spec
