source "http://rubygems.org"

if ENV['TRAVIS']
  # huge hack to work around bundler bug
  system "gem install selenium-webdriver --version 2.27.0.rc1"
  gem 'selenium-webdriver', '2.27.0.rc1'
else
  gem "simplecov", ">= 0.3.5", :platform => :ruby_19
end

# Specify your gem's dependencies in watir-webdriver.gemspec
gemspec
