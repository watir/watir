require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "watir2"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "jari.bakken@gmail.com"
    gem.homepage = "http://github.com/jarib/watir2"
    gem.authors = ["Jari Bakken"]
    gem.add_dependency "selenium-webdriver"
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "webidl"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

namespace :html5 do
  task :extract do
    raise NotImplementedError
    # http://dev.w3.org/html5/spec/Overview.html
  end

  desc 'Re-enerate the base Watir element classes from the spec '
  task :generate do
    require "support/html5/watir_visitor"
    code = WatirVisitor.generate_from("support/html5/html5.idl")

    File.open("lib/watir/elements/generated.rb", "w") { |file| file << code }
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "watir2 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
