# frozen_string_literal: true

require_relative 'lib/watir/version'

Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = Watir::VERSION
  s.required_ruby_version = '>= 2.5.0'

  s.platform = Gem::Platform::RUBY
  s.authors = ['Alex Rodionov', 'Titus Fortner', 'Justin Ko']
  s.email = %w[p0deje@gmail.com titusfortner@gmail.com jkotests@gmail.com]

  s.homepage = 'http://watir.com'
  s.summary = 'Watir powered by Selenium'
  s.description = <<~DESCRIPTION
    Watir stands for Web Application Testing In Ruby
    It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website.
  DESCRIPTION

  s.license = 'MIT'
  s.metadata = {
    'changelog_uri' => 'https://github.com/watir/watir/blob/main/rb/CHANGES.md',
    'source_code_uri' => 'https://github.com/watir/watir/tree/main/rb'
  }
  s.extra_rdoc_files = %w[LICENSE README.md CHANGES.md]
  s.files = Dir.glob('{lib/**/*}')
  s.require_paths = ['lib']

  s.add_dependency 'selenium-webdriver', '~> 4.0.0.beta1'
  s.add_runtime_dependency 'regexp_parser', '>= 1.2', '< 3'

  s.add_development_dependency 'activesupport', '~> 4.0', '>= 4.1.11' # for pluralization during code generation
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '>= 12.3.3'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-retry'
  s.add_development_dependency 'rubocop', '~> 0.59'
  s.add_development_dependency 'selenium_statistics'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-console'
  s.add_development_dependency 'webdrivers', '~> 4.1'
  s.add_development_dependency 'webidl', '>= 0.2.2'
  s.add_development_dependency 'yard', '> 0.8.2.1'
  s.add_development_dependency 'yard-doctest', '~> 0.1.14'
end
