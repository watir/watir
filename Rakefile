$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = %w[--color --require fuubar --format Fuubar]
  spec.pattern = 'spec/**/*_spec.rb'
  spec.exclude_pattern = 'spec/unit/**/*_spec.rb'
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

namespace :spec do
  RSpec::Core::RakeTask.new(:html) do |spec|
    spec.rspec_opts = "--format html --out #{ENV['SPEC_REPORT'] || 'specs.html'}"
    spec.pattern = 'spec/**/*_spec.rb'
  end
end

{
  html: 'https://www.w3.org/TR/html52/single-page.html',
  svg: 'http://www.w3.org/TR/SVG2/single-page.html'
}.each do |type, spec_uri|
  namespace type do
    spec_path = "support/#{type}.html"

    task generator_lib: :lib do
      require 'watir/generator'
    end

    desc "Download #{type.upcase} spec from #{spec_uri}"
    task :download do
      require 'open-uri'
      mv spec_path, "#{spec_path}.old" if File.exist?(spec_path)
      downloaded_bytes = 0

      File.open(spec_path, 'w') do |io|
        io << "<!--  downloaded from #{spec_uri} on #{Time.now} -->\n"
        io << data = URI.parse(spec_uri).read
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
        puts extractor.errors.join("\n" + '=' * 80 + "\n")
      end
    end

    desc 'Re-generate the base Watir element classes from the spec'
    task generate: :generator_lib do
      old_file = "lib/watir/elements/#{type}_elements.rb"
      generator = Watir::Generator.const_get(type.upcase).new

      File.open("#{old_file}.new", 'w') do |file|
        generator.generate(spec_path, file)
      end

      system "diff -Naut #{old_file} #{old_file}.new" if File.exist?(old_file)
    end

    desc "Move #{type}.rb.new to #{type}.rb"
    task :overwrite do
      file = "lib/watir/elements/#{type}_elements.rb"
      mv "#{file}.new", file
    end

    desc "download spec -> generate -> #{type}.rb"
    task update: %i[download generate overwrite]
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

task default: [:spec, 'yard:doctest']

namespace :spec do
  require 'selenium-webdriver'

  desc 'Run specs in all browsers'
  task all_browsers: %i[browsers remote_browsers]

  desc 'Run specs locally for all browsers'
  task browsers: [:chrome,
                  :firefox,
                  (:safari if Selenium::WebDriver::Platform.mac?),
                  (:ie if Selenium::WebDriver::Platform.windows?),
                  (:edge if Selenium::WebDriver::Platform.windows?)].compact

  desc 'Run specs remotely for all browsers'
  task remote_browsers: [:remote_chrome,
                         :remote_firefox,
                         (:remote_safari if Selenium::WebDriver::Platform.mac?),
                         (:remote_ie if Selenium::WebDriver::Platform.windows?),
                         (:remote_edge if Selenium::WebDriver::Platform.windows?)].compact

  %w[firefox chrome safari ie edge].each do |browser|
    desc "Run specs in #{browser}"
    task browser do
      ENV['WATIR_BROWSER'] = browser
      Rake::Task[:spec].execute
    end

    desc "Run specs in Remote #{browser}"
    task "remote_#{browser}" do
      ENV['WATIR_BROWSER'] = browser
      ENV['USE_REMOTE'] = 'true'
      Rake::Task[:spec].execute
    end
  end

  desc 'Run the Unit tests'
  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = 'spec/unit/**/**_spec.rb'
  end

  desc 'Run element location specs and report wire calls'
  RSpec::Core::RakeTask.new(:stats) do |spec|
    ENV['SELENIUM_STATS'] = 'true'
    spec.pattern = 'spec/**/**_spec.rb'
    spec.exclude_pattern = '**/window_switching_spec.rb, **/browser_spec.rb, **/after_hooks_spec.rb, ' \
                           '**/alert_spec.rb, **/wait_spec.rb, **/screenshot_spec.rb'
  end
end
