$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'bundler'
require 'watir-webdriver/version'
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
    spec.rspec_opts = "--format html --out #{ENV["SPEC_REPORT"] || "specs.html"}"
    spec.pattern    = 'spec/**/*_spec.rb'
  end
end

{
  html: 'https://www.whatwg.org/specs/web-apps/current-work/',
  svg: 'http://www.w3.org/TR/SVG2/single-page.html'
}.each do |type, spec_uri|
  namespace type do
    spec_path = "support/#{type}.html"

    task generator_lib: :lib do
      require "watir-webdriver/generator"
    end

    desc "Download #{type.upcase} spec from #{spec_uri}"
    task :download do
      require "open-uri"
      mv spec_path, "#{spec_path}.old" if File.exist?(spec_path)
      downloaded_bytes = 0

      File.open(spec_path, "w") do |io|
        io << "<!--  downloaded from #{spec_uri} on #{Time.now} -->\n"
        io << data = open(spec_uri).read
        downloaded_bytes = data.bytesize
      end

      puts "#{spec_uri} => #{spec_path} (#{downloaded_bytes} bytes)"
    end

    desc "Print IDL parts from #{spec_uri}"
    task print: :generator_lib do
      extractor = Watir::Generator.const_get("#{type.upcase}::SpecExtractor").new(spec_path)

      extractor.process.each do |tag_name, interface_definitions|
        puts "#{tag_name.ljust(10)} => #{interface_definitions.map(&:name)}"
      end

      extractor.print_hierarchy

      if extractor.errors.any?
        puts "\n\n<======================= ERRORS =======================>\n\n"
        puts extractor.errors.join("\n" + "=" * 80 + "\n")
      end
    end

    desc 'Re-generate the base Watir element classes from the spec'
    task generate: :generator_lib do
      old_file = "lib/watir-webdriver/elements/#{type}_elements.rb"
      generator = Watir::Generator.const_get(type.upcase).new

      File.open("#{old_file}.new", "w") do |file|
        generator.generate(spec_path, file)
      end

      if File.exist?(old_file)
        system "diff -Naut #{old_file} #{old_file}.new | less"
      end
    end

    desc "Move #{type}.rb.new to #{type}.rb"
    task :overwrite do
      file = "lib/watir-webdriver/elements/#{type}_elements.rb"
      mv "#{file}.new", file
    end

    desc "download spec -> generate -> #{type}.rb"
    task update: [:download, :generate, :overwrite]
  end
end

require 'yard'
YARD::Rake::YardocTask.new do |task|
  task.options = %w[--debug] # this is pretty slow, so nice with some output
end

require 'yard-doctest'
YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = ['-v']
end

namespace :changes do
  task :differ do
    require './support/version_differ'
  end

  desc 'Update CHANGES.md'
  task update: :differ do
    VersionDiffer.new.update('CHANGES.md')
  end

  desc 'Generate CHANGES.md from scratch'
  task generate: :differ do
    VersionDiffer.new.generate('CHANGES.md')
  end

  desc 'Print latest diff'
  task print: :differ do
    VersionDiffer.new.print_latest(STDOUT)
  end
end

load "spec/watirspec/watirspec.rake" if File.exist?("spec/watirspec/watirspec.rake")

task default: [:spec, 'yard:doctest']
