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

    gem.add_dependency "selenium-webdriver", ">= 0.0.10"

    gem.add_development_dependency "rspec"
    gem.add_development_dependency "webidl"
    gem.add_development_dependency "sinatra"
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
  IDL_PATH    = "support/html5/html5.idl"
  EXTRAS_PATH = "support/html5/html5_extras.idl"
  SPEC_URI    = "http://dev.w3.org/html5/spec/Overview.html" # TODO: use http://www.whatwg.org/specs/web-apps/current-work/source

  task :extract do
    require 'support/html5/idl_extractor'

    idl = IdlExtractor.new(SPEC_URI)
    idl.write_idl_to IDL_PATH
    idl.write_extras_to "#{EXTRAS_PATH}.txt"

    puts "\n\n"
    puts "Some HTML elements does not have an interface declaration defined in the spec."
    puts "You will need to create the IDL by hand and remove the .txt extension from #{EXTRAS_PATH}.txt before running the html5:generate task."
    puts "We're also adding an extended attribute to specify TagName - you may need to look through #{IDL_PATH} to make sure the syntax is correct."
  end

  desc 'Re-enerate the base Watir element classes from the spec '
  task :generate do
    require "support/html5/watir_visitor"
    raise Errno::ENOENT, EXTRAS_PATH unless File.exist?(EXTRAS_PATH)

    code = WatirVisitor.generate_from(IDL_PATH)
    code << "# from extras: \n\n"
    code << WatirVisitor.generate_from(EXTRAS_PATH)

    old_file = "lib/watir/elements/generated.rb"

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
  require 'support/yard/handlers/attributes_handler'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

load "spec/watirspec/watirspec.rake" if File.exist?("spec/watirspec/watirspec.rake")
