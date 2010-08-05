require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "watir-webdriver"
    gem.summary     = %Q{Watir on WebDriver}
    gem.description = %Q{WebDriver-backed Watir}
    gem.email       = "jari.bakken@gmail.com"
    gem.homepage    = "http://github.com/jarib/watir-webdriver"
    gem.authors     = ["Jari Bakken"]

    gem.add_dependency "selenium-webdriver", '>= 0.0.26'

    gem.add_development_dependency "rspec"
    gem.add_development_dependency "webidl"
    gem.add_development_dependency "sinatra", ">= 1.0"
    gem.add_development_dependency "activesupport", ">= 2.3.5" # for pluralization during code generation
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
  spec.rcov_opts = %w[--exclude spec,ruby-debug,/Library/Ruby,.gem --include lib/watir-webdriver]
end

task :spec => :check_dependencies

namespace :html5 do
  IDL_PATH  = "support/html5/html5.idl"
  SPEC_URI  = "http://www.whatwg.org/specs/web-apps/current-work/"
  SPEC_PATH = "support/html5/html5-2010-08-05.html"

  desc "Print IDL parts from #{SPEC_URI}"
  task :extract do
    require 'support/html5/spec_extractor'
    result = SpecExtractor.new(SPEC_PATH).process
    
    result.each do |tag_name, interface_definitions|
      puts "#{tag_name.ljust(10)} => #{interface_definitions.map { |e| e.name }}"
    end
  end

  desc 'Re-enerate the base Watir element classes from the spec '
  task :generate do
    require "support/html5/watir_visitor"

    code = WatirVisitor.generate_from(IDL_PATH)
    old_file = "lib/watir-webdriver/elements/generated.rb"

    File.open("#{old_file}.new", "w") { |file| file << code }
    if File.exist?(old_file)
      system "diff -Naut #{old_file} #{old_file}.new | less"
    end
  end

  desc 'Check the syntax of support/html5/*.idl'
  task :syntax do
    require 'webidl'
    parser = WebIDL::Parser::IDLParser.new
    failures = []
    
    Dir['support/html5/*.idl'].each do |path|
      unless parser.parse(File.read(path))
        failures << [path, parser.failure_reason]
      end
    end

    if failures.any?
      puts "Parse errors!"
      failures.each { |path, reason| puts "#{path.ljust(40)}: #{reason}"  }
    else
      puts "Syntax OK."
    end
  end

end # html5

task :default => :spec

begin
  require 'yard'
  require 'support/yard_handlers'
  YARD::Rake::YardocTask.new do |task|
    task.options = %w[--debug] # this is pretty slow, so nice with some output
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

load "spec/watirspec/watirspec.rake" if File.exist?("spec/watirspec/watirspec.rake")
