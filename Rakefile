require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts  = "-I lib:spec"
  spec.rspec_opts = %w[--color --require fuubar --format Fuubar]
  spec.pattern    = 'spec/**/*_spec.rb'
end

namespace :spec do
  RSpec::Core::RakeTask.new(:html) do |spec|
    spec.ruby_opts  = "-I lib:spec"
    spec.pattern    = 'spec/**/*_spec.rb'
    spec.rspec_opts = "--format html --out #{ENV["SPEC_REPORT"] || "specs.html"}"
  end
end

task :default => :spec



task :lib do
  $LOAD_PATH.unshift(File.expand_path("lib", File.dirname(__FILE__)))
end

namespace :html5 do
  SPEC_URI  = "http://www.whatwg.org/specs/web-apps/current-work/"
  SPEC_PATH = "support/html5.html"

  task :html_lib => :lib do
    require 'watir-webdriver/html'
  end

  desc "Download the HTML5 spec from #{SPEC_URI}"
  task :download do
    require "open-uri"
    mv SPEC_PATH, "#{SPEC_PATH}.old" if File.exist?(SPEC_PATH)
    downloaded_bytes = 0

    File.open(SPEC_PATH, "w") do |io|
      io << "<!--  downloaded from #{SPEC_URI} on #{Time.now} -->\n"
      io << data = open(SPEC_URI).read
      downloaded_bytes = data.bytesize
    end

    puts "#{SPEC_URI} => #{SPEC_PATH} (#{downloaded_bytes} bytes)"
  end

  desc "Print IDL parts from #{SPEC_URI}"
  task :print => :html_lib do
    extractor = Watir::HTML::SpecExtractor.new(SPEC_PATH)

    extractor.process.each do |tag_name, interface_definitions|
      puts "#{tag_name.ljust(10)} => #{interface_definitions.map { |e| e.name }}"
    end

    extractor.print_hierarchy

    unless extractor.errors.empty?
      puts "\n\n<======================= ERRORS =======================>\n\n"
      puts extractor.errors.join("\n" + "="*80 + "\n")
    end
  end

  desc 'Re-enerate the base Watir element classes from the spec '
  task :generate => :html_lib do
    old_file = "lib/watir-webdriver/elements/generated.rb"
    generator = Watir::HTML::Generator.new

    File.open("#{old_file}.new", "w") do |file|
      generator.generate(SPEC_PATH, file)
    end

    if File.exist?(old_file)
      system "diff -Naut #{old_file} #{old_file}.new | less"
    end
  end

  desc 'Move generated.rb.new to generated.rb'
  task :overwrite do
    file = "lib/watir-webdriver/elements/generated.rb"
    mv "#{file}.new", file
  end

  desc 'download spec -> generate -> generated.rb'
  task :update => [:download, :generate, :overwrite]
end # html5

begin
  require 'yard'
  Rake::Task[:lib].invoke
  require "yard/handlers/watir"
  YARD::Rake::YardocTask.new do |task|
    task.options = %w[--debug] # this is pretty slow, so nice with some output
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

load "spec/watirspec/watirspec.rake" if File.exist?("spec/watirspec/watirspec.rake")
