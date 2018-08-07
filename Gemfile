# frozen_string_literal: true

source 'http://rubygems.org'

gem 'simplecov', '>= 0.3.5', platform: :ruby_19 unless ENV['TRAVIS']

gem 'webidl', path: File.expand_path('../webidl') if ENV['LOCAL_WEBIDL']

gem 'selenium-webdriver', path: File.expand_path('../selenium/build/rb') if ENV['LOCAL_SELENIUM']

# Specify your gem's dependencies in watir.gemspec
gemspec
