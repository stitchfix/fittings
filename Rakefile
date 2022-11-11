require 'rubygems/package_task'
require 'rspec/core/rake_task'

$: << File.join(File.dirname(__FILE__),'lib')
require 'stitch_fix/y/tasks'

include Rake::DSL

gemspec = Gem::Specification.load('fittings.gemspec')
Gem::PackageTask.new(gemspec) {}
RSpec::Core::RakeTask.new(:spec)
StitchFix::Y::ReleaseTask.for_rubygems(gemspec)
StitchFix::Y::VersionTask.for_rubygems(gemspec)

task :default => :spec
