# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'watir'
  s.version     = '6.10.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alex Rodionov', 'Titus Fortner']
  s.email       = ['p0deje@gmail.com', 'titusfortner@gmail.com']
  s.homepage    = 'http://github.com/watir/watir'
  s.summary     = 'Watir powered by Selenium'
  s.description = <<-DESCRIPTION_MESSAGE
Watir stands for Web Application Testing In Ruby
It facilitates the writing of automated tests by mimicing the behavior of a user interacting with a website.
  DESCRIPTION_MESSAGE

  s.license     = 'MIT'
  s.rubyforge_project = 'watir'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'selenium-webdriver', '~> 3.4', '>= 3.4.1'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'yard', '> 0.8.2.1'
  s.add_development_dependency 'webidl', '>= 0.2.0'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'activesupport', '~> 4.0', '>= 4.1.11' # for pluralization during code generation
  s.add_development_dependency 'pry'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'yard-doctest', '>= 0.1.8'
  s.add_development_dependency 'webdrivers', '~> 3.0', '>= 3.1.0'
end
