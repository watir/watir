lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'watir/version'

Gem::Specification.new do |s|
  s.name = 'watir'
  s.version = Watir::VERSION
  s.required_ruby_version = '>= 2.3.0'

  s.platform = Gem::Platform::RUBY
  s.authors = ['Alex Rodionov', 'Titus Fortner', 'Justin Ko']
  s.email = ['p0deje@gmail.com', 'titusfortner@gmail.com', 'jkotests@gmail.com ']
  s.homepage = 'http://github.com/watir/watir'
  s.summary = 'Watir powered by Selenium'
  s.description = <<~DESCRIPTION_MESSAGE
    Watir stands for Web Application Testing In Ruby
    It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website.
  DESCRIPTION_MESSAGE

  s.license = 'MIT'
  s.rubyforge_project = 'watir'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'selenium-webdriver', '~> 3.6'
  s.add_runtime_dependency 'regexp_parser', '~>1.2'

  s.add_development_dependency 'activesupport', '~> 4.0', '>= 4.1.11' # for pluralization during code generation
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-retry'
  s.add_development_dependency 'rubocop', '~> 0.59'
  s.add_development_dependency 'selenium_statistics'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-console'
  s.add_development_dependency 'webdrivers', '~> 3.5.2'
  s.add_development_dependency 'webidl', '>= 0.2.2'
  s.add_development_dependency 'yard', '> 0.8.2.1'
  s.add_development_dependency 'yard-doctest', '>= 0.1.8'
end
