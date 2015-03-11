source "http://rubygems.org"

unless ENV['TRAVIS']
  gem "simplecov", ">= 0.3.5", :platform => :ruby_19
end

if ENV['LOCAL_WEBIDL']
  gem 'webidl', path: File.expand_path('../webidl')
end

gem 'selenium-webdriver', :github => 'titusfortner/selenium', :branch => 'firefox_fix'

# Specify your gem's dependencies in watir-webdriver.gemspec
gemspec
