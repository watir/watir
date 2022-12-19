source 'https://rubygems.org'

gem 'webidl', path: File.expand_path('../webidl') if ENV['LOCAL_WEBIDL']

if ENV['LOCAL_SELENIUM']
  ENV['RUBYOPT'] = "-I../selenium/bazel-bin/rb"
  gem 'selenium-webdriver', path: File.expand_path('../selenium/rb')
end

gem 'ffi' if Gem.win_platform? # For selenium-webdriver on Windows

# Specify your gem's dependencies in watir.gemspec
gemspec
