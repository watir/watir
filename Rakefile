require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "watir2"
    gem.summary     = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email       = "jari.bakken@gmail.com"
    gem.homepage    = "http://github.com/jarib/watir2"
    gem.authors     = ["Jari Bakken"]

    gem.add_dependency "selenium-webdriver"

    gem.add_development_dependency "rspec"
    gem.add_development_dependency "webidl"
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
  IDL_PATH    = "support/html5/html5.idl"
  EXTRAS_PATH = "support/html5/html5_extras.idl"
  SPEC_URI    = "http://dev.w3.org/html5/spec/Overview.html"
  
  task :extract do
    require 'support/html5/idl_extractor'

    idl = IdlExtractor.new(SPEC_URI)
    idl.write_idl_to IDL_PATH
    idl.write_extras_to "#{EXTRAS_PATH}.txt"

    puts "\n\n"
    puts "Some HTML elements does not have an interface declaration defined in the spec."
    puts "You will need to create the IDL by hand and remove the .txt extension from #{EXTRAS_PATH}.txt before running the html5:generate task."
  end

  desc 'Re-enerate the base Watir element classes from the spec '
  task :generate do
    require "support/html5/watir_visitor"
    raise Errno::ENOENT, EXTRAS_PATH unless File.exist?(EXTRAS_PATH)
    
    code = WatirVisitor.generate_from(IDL_PATH)
    code << "# from extras: \n\n"
    code << WatirVisitor.generate_from(EXTRAS_PATH)
    
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
