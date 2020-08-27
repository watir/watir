source 'https://rubygems.org'

gem 'webidl', path: File.expand_path('../webidl') if ENV['LOCAL_WEBIDL']

gem 'selenium-webdriver', path: File.expand_path('../selenium/build/rb') if ENV['LOCAL_SELENIUM']

gem 'ffi' if Gem.win_platform? # For selenium-webdriver on Windows

# Specify your gem's dependencies in watir.gemspec
gemspec
