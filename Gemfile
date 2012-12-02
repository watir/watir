source "http://rubygems.org"

if ENV['TRAVIS']
  # Travis is now running Firefox 17
  # remove this when 2.27 is released
  gem 'selenium-webdriver', '= 2.27.0.rc1'
else
  gem "simplecov", ">= 0.3.5", :platform => :ruby_19
end

# Specify your gem's dependencies in watir-webdriver.gemspec
gemspec
