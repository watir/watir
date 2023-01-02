# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'watir/version'

Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = Watir::VERSION
  s.required_ruby_version = '>= 2.7.0'

  s.platform = Gem::Platform::RUBY
  s.authors = ['Alex Rodionov', 'Titus Fortner', 'Justin Ko']
  s.email = ['p0deje@gmail.com', 'titusfortner@gmail.com', 'jkotests@gmail.com ']
  s.homepage = 'https://github.com/watir/watir'
  s.summary = 'Watir powered by Selenium'
  s.description = <<~DESCRIPTION_MESSAGE
    Watir stands for Web Application Testing In Ruby
    It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website.
  DESCRIPTION_MESSAGE

  s.license = 'MIT'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'regexp_parser', '>= 1.2', '< 3'
  s.add_runtime_dependency 'selenium-webdriver', '~> 4.2'

  s.add_development_dependency 'activesupport', '~> 4.0', '>= 4.1.11' # for pluralization during code generation
  s.add_development_dependency 'coveralls_reborn'
  s.add_development_dependency 'nokogiri', '~> 1.13'
  s.add_development_dependency 'pry', '~> 0.14'
  s.add_development_dependency 'rake', '>= 12.3.3'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-retry'
  s.add_development_dependency 'rubocop', '~> 1.42'
  s.add_development_dependency 'rubocop-performance', '~> 1.15'
  s.add_development_dependency 'rubocop-rake', '~> 0.6'
  s.add_development_dependency 'rubocop-rspec', '~> 2.16'
  s.add_development_dependency 'selenium_statistics'
  s.add_development_dependency 'selenium-webdriver', '~> 4.7'
  s.add_development_dependency 'simplecov-console'
  s.add_development_dependency 'webidl', '>= 0.2.2'
  s.add_development_dependency 'yard', '> 0.9.11'
  s.add_development_dependency 'yard-doctest', '~> 0.1.14'
end
